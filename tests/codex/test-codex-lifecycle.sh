#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
HOOK="$ROOT/hooks/codex-lifecycle"
CLAUDE="$ROOT/templates/hooks/drift-check"
WINDOWS_LAUNCHER="$(grep -m1 '"commandWindows"' "$ROOT/hooks/hooks.json" | sed 's/.*"commandWindows": "\(.*\)",/\1/' | sed 's/\\"/"/g; s/\\\\/\\/g')"

repo() {
  local dir="$1"
  git -C "$dir" init -q
  git -C "$dir" config user.email t@t.t
  git -C "$dir" config user.name t
  mkdir -p "$dir/.aiboarding/tools"
  cp "$ROOT/templates/tools/classify-drift" "$dir/.aiboarding/tools/classify-drift"
  printf 'base\n' > "$dir/file.txt"
  git -C "$dir" add .
  git -C "$dir" commit -qm base
}

payload() { printf '{"hook_event_name":"%s","cwd":"%s"%s}' "$1" "$2" "${3:-}"; }
run() { PLUGIN_ROOT="$ROOT" bash "$HOOK"; }
run_windows() { PLUGIN_ROOT="$(cygpath -w "$ROOT")" AIBOARDING_WINDOWS_LAUNCHER="$WINDOWS_LAUNCHER" powershell.exe -NoLogo -NoProfile -NonInteractive -Command '$utf8 = New-Object System.Text.UTF8Encoding($false); [Console]::InputEncoding = $utf8; [Console]::OutputEncoding = $utf8; $payload = [Console]::In.ReadToEnd(); $psi = New-Object System.Diagnostics.ProcessStartInfo; $psi.FileName = $env:ComSpec; $psi.Arguments = "/C `"" + $env:AIBOARDING_WINDOWS_LAUNCHER + "`""; $psi.UseShellExecute = $false; $psi.RedirectStandardInput = $true; $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true; $process = New-Object System.Diagnostics.Process; $process.StartInfo = $psi; [void]$process.Start(); $bytes = $utf8.GetBytes($payload); $process.StandardInput.BaseStream.Write($bytes, 0, $bytes.Length); $process.StandardInput.Close(); [Console]::Out.Write($process.StandardOutput.ReadToEnd()); [Console]::Error.Write($process.StandardError.ReadToEnd()); $process.WaitForExit(); exit $process.ExitCode'; }
state() { mkdir -p "$1/.aiboarding"; printf '{\n  "last_synced_commit": "%s"\n}\n' "$2" > "$1/.aiboarding/state.json"; }

tmp="$(mktemp -d)/repo with spaces"
mkdir -p "$tmp"
trap 'rm -rf "$tmp"' EXIT
repo "$tmp"
base="$(git -C "$tmp" rev-parse HEAD)"

# Invalid/mismatched payloads never make noise.
out="$(printf '{}' | run)"
assert_eq "$out" "" "malformed input is silent" || exit 1
out="$(payload PostToolUse "$tmp" ',"tool_name":"Edit","tool_input":{"command":"git status"}' | run)"
assert_eq "$out" "" "non-Bash PostToolUse is silent" || exit 1

# Startup/subagent decisions use native AGENTS.md delivery, never its body.
printf '# AGENTS\nCANARY-BODY\n' > "$tmp/AGENTS.md"
out="$(payload SessionStart "$tmp" | run)"
assert_eq "$out" "" "valid startup is silent" || exit 1
out="$(payload SubagentStart "$tmp" | run)"
assert_contains "$out" 'read AGENTS.md' "subagent receives pointer" || exit 1
assert_not_contains "$out" 'CANARY-BODY' "subagent never receives body" || exit 1
rm "$tmp/AGENTS.md"
out="$(payload SessionStart "$tmp" | run)"
assert_contains "$out" 'create-agent-onboarding' "missing startup names create skill" || exit 1
printf '# legacy\n' > "$tmp/AIBOARDING.md"
out="$(payload SessionStart "$tmp" | run)"
assert_contains "$out" 'migrate-aiboarding' "legacy startup names migration" || exit 1
out="$(payload SubagentStart "$tmp" | run)"
assert_eq "$out" "" "absent onboarding keeps subagent silent" || exit 1
rm "$tmp/AIBOARDING.md"

# Git drift: non-Git/in-sync/irrelevant remain silent; relevant and uncertain signal.
state "$tmp" "$base"
out="$(payload PostToolUse "$tmp" ',"tool_name":"Bash","tool_input":{"command":"echo git"}' | run)"
assert_eq "$out" "" "non-Git Bash command is silent" || exit 1
out="$(payload PostToolUse "$tmp" ',"tool_name":"Bash","tool_input":{"command":"git status"}' | run)"
assert_eq "$out" "" "in-sync is silent" || exit 1
printf '# AGENTS\n' > "$tmp/AGENTS.md"
git -C "$tmp" add AGENTS.md && git -C "$tmp" commit -qm onboarding
out="$(payload PostToolUse "$tmp" ',"tool_name":"Bash","tool_input":{"command":"git status"}' | run)"
assert_eq "$out" "" "irrelevant range is silent" || exit 1
printf 'changed\n' >> "$tmp/file.txt"
git -C "$tmp" add file.txt && git -C "$tmp" commit -qm code
out="$(payload PostToolUse "$tmp" ',"tool_name":"Bash","tool_input":{"command":"git commit -m x"}' | run)"
assert_contains "$out" 'semantic-review' "relevant range signals shared route" || exit 1
if [ "${OS:-}" = Windows_NT ] && command -v cmd.exe >/dev/null 2>&1; then
  windows_cwd="$(cygpath -m "$tmp")"
  out="$(payload PostToolUse "$windows_cwd" ',"tool_name":"Bash","tool_input":{"command":"echo git"}' | run_windows)"
  assert_eq "$out" "" "native commandWindows launcher keeps non-Git Bash silent" || exit 1
  out="$(payload PostToolUse "$windows_cwd" ',"tool_name":"Bash","tool_input":{"command":"git commit -m x"}' | run_windows)"
  assert_contains "$out" '<aiboarding-drift>' "native commandWindows launcher returns drift context" || exit 1
fi
out="$(printf '{"tool_name":"Bash","tool_input":{"command":"git commit -m x"}' | CLAUDE_PROJECT_DIR="$tmp" bash "$CLAUDE")"
assert_contains "$out" 'semantic-review' "Claude receives same route" || exit 1
state "$tmp" ""
out="$(payload PostToolUse "$tmp" ',"tool_name":"Bash","tool_input":{"command":"git status"}' | run)"
assert_contains "$out" 'invalid-pointer' "uncertain state signals repair" || exit 1

printf 'PASS: codex lifecycle\n'

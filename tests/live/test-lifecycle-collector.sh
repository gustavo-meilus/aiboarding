#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/.aiboarding/hooks" "$tmp/.aiboarding/tools"
for file in _lib session-start subagent-start drift-check instructions-loaded; do
  cp "$ROOT/templates/hooks/$file" "$tmp/.aiboarding/hooks/$file"
  cmp "$ROOT/templates/hooks/$file" "$tmp/.aiboarding/hooks/$file" || exit 1
done
cp "$ROOT/templates/tools/lifecycle-decision" "$tmp/.aiboarding/tools/lifecycle-decision"
cp "$ROOT/templates/tools/classify-drift" "$tmp/.aiboarding/tools/classify-drift"
chmod +x "$tmp/.aiboarding/tools/classify-drift"
cp "$ROOT/tests/live/collector.sh" "$tmp/.aiboarding/hooks/collector"
chmod +x "$tmp/.aiboarding/hooks/collector"

# Collector is evidence-only: it records input and never emits hook context.
payload='{"hook_event_name":"SessionStart","session_id":"case-session"}'
out="$(printf '%s' "$payload" | bash "$tmp/.aiboarding/hooks/collector" "$tmp/collector.jsonl")"
assert_eq "$out" "" "collector stays silent" || exit 1
recorded="$(<"$tmp/collector.jsonl")"
assert_contains "$recorded" 'case-session' "collector retains runtime input" || exit 1

if [ "${OS:-}" = Windows_NT ] && command -v cmd.exe >/dev/null 2>&1; then
  wrapper="$(cygpath -w "$ROOT/templates/hooks/run-hook.cmd")"
  collector="$(cygpath -w "$tmp/.aiboarding/hooks/collector")"
  windows_file="$(cygpath -w "$tmp/collector-windows.jsonl")"
  printf '%s' "$payload" | cmd.exe /d /s /c "\"$wrapper\" \"$collector\" \"$windows_file\"" >/dev/null
  assert_contains "$(<"$tmp/collector-windows.jsonl")" 'case-session' "Windows wrapper runs collector" || exit 1
fi

# A copied production hook remains independently attributable and silent for a valid layout.
printf 'CANARY\n' > "$tmp/AGENTS.md"
printf '@AGENTS.md\n' > "$tmp/CLAUDE.md"
out="$(CLAUDE_PROJECT_DIR="$tmp" bash "$tmp/.aiboarding/hooks/session-start")"
assert_eq "$out" "" "valid session layout is silent" || exit 1
printf '# missing import\n' > "$tmp/CLAUDE.md"
out="$(CLAUDE_PROJECT_DIR="$tmp" bash "$tmp/.aiboarding/hooks/session-start")"
assert_contains "$out" '<aiboarding-missing>' "broken wrapper delivers repair context" || exit 1

# The debug-only production hook logs independently; debug-off leaves no log.
payload='{"hook_event_name":"InstructionsLoaded","file_path":"/case/CLAUDE.md","load_reason":"session_start"}'
printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$tmp" bash "$tmp/.aiboarding/hooks/instructions-loaded"
[ ! -e "$tmp/.aiboarding/logs/hooks.log" ] || { printf 'FAIL: debug-off wrote a log\n'; exit 1; }
printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$tmp" AIBOARDING_DEBUG=1 bash "$tmp/.aiboarding/hooks/instructions-loaded"
assert_contains "$(<"$tmp/.aiboarding/logs/hooks.log")" '/case/CLAUDE.md' "debug log records loaded file" || exit 1

# Subagent delivery is a pointer only; absent onboarding remains silent.
printf 'CANARY\n' > "$tmp/AGENTS.md"
out="$(CLAUDE_PROJECT_DIR="$tmp" bash "$tmp/.aiboarding/hooks/subagent-start")"
assert_contains "$out" '<aiboarding-pointer>' "subagent receives pointer" || exit 1
assert_not_contains "$out" 'CANARY' "subagent never receives onboarding body" || exit 1
rm "$tmp/AGENTS.md"
out="$(CLAUDE_PROJECT_DIR="$tmp" bash "$tmp/.aiboarding/hooks/subagent-start")"
assert_eq "$out" "" "absent onboarding keeps subagent silent" || exit 1

# Drift self-gates non-Git input and emits a route for a qualifying Git range.
git -C "$tmp" init -q
git -C "$tmp" config user.email live@test.invalid
git -C "$tmp" config user.name live
printf 'base\n' > "$tmp/file.txt"
git -C "$tmp" add . && git -C "$tmp" commit -qm base
base="$(git -C "$tmp" rev-parse HEAD)"
printf '{"last_synced_commit":"%s"}\n' "$base" > "$tmp/.aiboarding/state.json"
printf 'changed\n' >> "$tmp/file.txt"
git -C "$tmp" add file.txt && git -C "$tmp" commit -qm changed
out="$(printf '{"tool_name":"Bash","tool_input":{"command":"echo hi"}}' | CLAUDE_PROJECT_DIR="$tmp" bash "$tmp/.aiboarding/hooks/drift-check")"
assert_eq "$out" "" "non-Git event remains silent" || exit 1
out="$(printf '{"tool_name":"Bash","tool_input":{"command":"git status"}}' | CLAUDE_PROJECT_DIR="$tmp" bash "$tmp/.aiboarding/hooks/drift-check")"
assert_contains "$out" '<aiboarding-drift>' "Git event delivers drift context" || exit 1
printf 'PASS: lifecycle collector\n'

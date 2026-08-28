#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
WRAP="$ROOT/templates/hooks/run-hook.cmd"

# The wrapper, run under bash, should dispatch to the named sibling script.
out="$(CLAUDE_PROJECT_DIR="$ROOT/tests/fixtures/with-doc" bash "$WRAP" session-start)"; rc=$?
assert_eq "$rc" "0" "wrapper propagates exit 0 from dispatched script" || exit 1
assert_contains "$out" '"hookEventName":"SessionStart"' "wrapper dispatches to session-start" || exit 1

# An explicit script path supports plugin-level adapters outside the wrapper directory.
out="$(CLAUDE_PROJECT_DIR="$ROOT/tests/fixtures/with-doc" bash "$WRAP" "$ROOT/templates/hooks/session-start")"; rc=$?
assert_eq "$rc" "0" "wrapper accepts an explicit script path" || exit 1
assert_contains "$out" '"hookEventName":"SessionStart"' "wrapper dispatches explicit scripts" || exit 1

# Missing script name -> nonzero exit, message on stderr.
if err="$(bash "$WRAP" 2>&1)"; then
  printf 'FAIL: wrapper should fail with no script name\n'; exit 1
fi
assert_contains "$err" "missing script name" "wrapper reports missing name" || exit 1

cmp -s "$ROOT/templates/hooks/run-hook.cmd" "$ROOT/.aiboarding/hooks/run-hook.cmd" || { printf 'FAIL: self-host wrapper differs from template\n'; exit 1; }
assert_not_contains "$(cat "$WRAP")" 'where bash' "Windows wrapper never falls through to WSL Bash" || exit 1

if [ "${OS:-}" = Windows_NT ] && command -v cmd.exe >/dev/null 2>&1; then
  win_wrap="$(cygpath -w "$WRAP")"
  if out="$(AIBOARDING_WIN_WRAP="$win_wrap" powershell.exe -NoLogo -NoProfile -NonInteractive -Command '$psi = New-Object System.Diagnostics.ProcessStartInfo; $psi.FileName = $env:ComSpec; $psi.Arguments = "/d /c `"`"$env:AIBOARDING_WIN_WRAP`" `"$env:AIBOARDING_WIN_WRAP`"`""; $psi.UseShellExecute = $false; $psi.RedirectStandardOutput = $true; $psi.EnvironmentVariables["ProgramFiles"] = "C:\\missing"; $psi.EnvironmentVariables["ProgramFiles(x86)"] = "C:\\missing"; $psi.EnvironmentVariables["PATH"] = "$env:SystemRoot\\System32"; $process = New-Object System.Diagnostics.Process; $process.StartInfo = $psi; [void]$process.Start(); [Console]::Out.Write($process.StandardOutput.ReadToEnd()); $process.WaitForExit(); exit $process.ExitCode')"; then
    assert_eq "$out" "" "Windows wrapper is silent without compatible Git Bash" || exit 1
  else
    printf 'FAIL: Windows wrapper should succeed without compatible Git Bash\n'; exit 1
  fi
fi

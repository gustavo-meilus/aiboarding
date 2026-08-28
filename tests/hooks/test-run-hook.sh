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
  if out="$(cmd.exe /d /s /c "set \"ProgramFiles=C:\\missing\" & set \"ProgramFiles(x86)=C:\\missing\" & set \"PATH=%SystemRoot%\\System32\" & \"$win_wrap\" \"$win_wrap\"")"; then
    assert_eq "$out" "" "Windows wrapper is silent without compatible Git Bash" || exit 1
  else
    printf 'FAIL: Windows wrapper should succeed without compatible Git Bash\n'; exit 1
  fi
fi

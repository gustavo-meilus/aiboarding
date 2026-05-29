#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
WRAP="$ROOT/templates/hooks/run-hook.cmd"

# The wrapper, run under bash, should dispatch to the named sibling script.
out="$(CLAUDE_PROJECT_DIR="$ROOT/tests/fixtures/with-doc" bash "$WRAP" session-start)"; rc=$?
assert_eq "$rc" "0" "wrapper propagates exit 0 from dispatched script" || exit 1
assert_contains "$out" '"hookEventName":"SessionStart"' "wrapper dispatches to session-start" || exit 1

# Missing script name -> nonzero exit, message on stderr.
if err="$(bash "$WRAP" 2>&1)"; then
  printf 'FAIL: wrapper should fail with no script name\n'; exit 1
fi
assert_contains "$err" "missing script name" "wrapper reports missing name" || exit 1

#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
HOOK="$ROOT/templates/hooks/pre-task"

# With a doc: emit PreToolUse context carrying the doc.
out="$(CLAUDE_PROJECT_DIR="$ROOT/tests/fixtures/with-doc" bash "$HOOK")"; rc=$?
assert_eq "$rc" "0" "pre-task exits 0 with doc" || exit 1
assert_contains "$out" '"hookEventName":"PreToolUse"' "emits PreToolUse event" || exit 1
assert_contains "$out" 'Invoicing for freelancers.' "sub-agent receives doc body" || exit 1

# With no doc: no output at all (empty), no fallback.
out_missing="$(CLAUDE_PROJECT_DIR="$ROOT/tests/fixtures/no-doc" bash "$HOOK")"; rc_missing=$?
assert_eq "$rc_missing" "0" "pre-task exits 0 without doc" || exit 1
assert_eq "$out_missing" "" "no output when doc missing" || exit 1

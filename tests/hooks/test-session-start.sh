#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
HOOK="$ROOT/templates/hooks/session-start"

# With a doc present: output carries the body inside aiboarding-context, as CC JSON.
out="$(CLAUDE_PROJECT_DIR="$ROOT/tests/fixtures/with-doc" bash "$HOOK")"
assert_contains "$out" '"hookEventName":"SessionStart"' "emits SessionStart event" || exit 1
assert_contains "$out" '<aiboarding-context>' "wraps doc in context tag" || exit 1
assert_contains "$out" 'Invoicing for freelancers.' "includes doc body" || exit 1
assert_contains "$out" 'do not assume NextAuth.' "includes AI-context section" || exit 1

# With no doc: output is the missing-doc fallback prompting create-aiboarding.
out_missing="$(CLAUDE_PROJECT_DIR="$ROOT/tests/fixtures/no-doc" bash "$HOOK")"
assert_contains "$out_missing" 'create-aiboarding' "fallback names create-aiboarding" || exit 1
assert_not_contains "$out_missing" '<aiboarding-context>' "no context tag when doc missing" || exit 1

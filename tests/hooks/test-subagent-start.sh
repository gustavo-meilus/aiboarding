#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
HOOK="$ROOT/templates/hooks/subagent-start"

# 1. AGENTS.md present: short pointer with the binding sections named.
out="$(CLAUDE_PROJECT_DIR="$ROOT/tests/fixtures/modern" bash "$HOOK")"
assert_contains "$out" '"hookEventName":"SubagentStart"' "emits SubagentStart" || exit 1
assert_contains "$out" '<aiboarding-pointer>' "emits the pointer tag" || exit 1
assert_contains "$out" 'read AGENTS.md' "pointer names AGENTS.md" || exit 1
assert_contains "$out" 'Agent Guardrails' "pointer names the binding sections" || exit 1

# 2. Anti-regression vs the retired pre-task hook: the pointer must never
#    carry the document body.
assert_not_contains "$out" 'CANARY-AGENTS-BODY-9C2E' "pointer does not inject the doc body" || exit 1
assert_not_contains "$out" 'Invoicing for freelancers' "pointer does not inject fixture content" || exit 1

# 3. No AGENTS.md: silent.
out="$(CLAUDE_PROJECT_DIR="$ROOT/tests/fixtures/no-doc" bash "$HOOK")"
assert_eq "$out" "" "silent when AGENTS.md is absent" || exit 1

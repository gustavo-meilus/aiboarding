#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
HOOK="$ROOT/templates/hooks/session-start"

# 1. Modern layout (AGENTS.md + CLAUDE.md with @AGENTS.md): silent - native
#    loading covers delivery; the hook must not duplicate it.
out="$(CLAUDE_PROJECT_DIR="$ROOT/tests/fixtures/modern" bash "$HOOK")"
assert_eq "$out" "" "silent when the modern layout is complete" || exit 1

# 2. Wrapper without the import line: warning names the fix, no doc body.
out="$(CLAUDE_PROJECT_DIR="$ROOT/tests/fixtures/partial" bash "$HOOK")"
assert_contains "$out" '"hookEventName":"SessionStart"' "partial layout emits SessionStart" || exit 1
assert_contains "$out" '@AGENTS.md' "partial layout names the missing import line" || exit 1
assert_not_contains "$out" 'CLAUDE.md wrapper lacks' "does not emit AGENTS.md body content" || exit 1

# 3. Legacy layout (AIBOARDING.md, no AGENTS.md): migration nudge, no body.
out="$(CLAUDE_PROJECT_DIR="$ROOT/tests/fixtures/with-doc" bash "$HOOK")"
assert_contains "$out" '<aiboarding-legacy>' "legacy layout emits the legacy tag" || exit 1
assert_contains "$out" 'migrate-aiboarding' "legacy nudge names migrate-aiboarding" || exit 1
assert_not_contains "$out" 'Invoicing for freelancers' "legacy nudge does not inject the doc body" || exit 1

# 4. Nothing at all: missing-files fallback naming create-agent-onboarding.
out="$(CLAUDE_PROJECT_DIR="$ROOT/tests/fixtures/no-doc" bash "$HOOK")"
assert_contains "$out" '<aiboarding-missing>' "missing layout emits the missing tag" || exit 1
assert_contains "$out" 'AGENTS.md and CLAUDE.md' "missing message names both files" || exit 1
assert_contains "$out" 'create-agent-onboarding' "missing message names the create skill" || exit 1

# 5. AGENTS.md present but no CLAUDE.md: names only the missing wrapper.
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
printf '# AGENTS.md\n' > "$tmp/AGENTS.md"
out="$(CLAUDE_PROJECT_DIR="$tmp" bash "$HOOK")"
assert_contains "$out" 'No CLAUDE.md found' "names only the missing wrapper" || exit 1
assert_not_contains "$out" 'AGENTS.md and CLAUDE.md' "does not claim AGENTS.md is missing" || exit 1

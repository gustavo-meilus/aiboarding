#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
skill="$(cat "$ROOT/skills/audit-agent-onboarding/SKILL.md")"

assert_contains "$skill" 'audit-onboarding-evidence <repo-root>' 'audit runs deterministic validator first' || exit 1
assert_contains "$skill" 'Codex project-chain budget' 'audit distinguishes chain budget from local guidance' || exit 1
assert_contains "$skill" '`2` is an operational error' 'operational errors stop audit' || exit 1
assert_contains "$skill" 'FAIL [computed] wrapper-integrity' 'mixed report shows computed provenance' || exit 1
assert_contains "$skill" 'WARN [inferred] vague-commands' 'mixed report shows inferred provenance' || exit 1

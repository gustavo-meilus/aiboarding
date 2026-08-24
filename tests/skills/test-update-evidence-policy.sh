#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
skill="$(cat "$ROOT/skills/update-agent-onboarding/SKILL.md")"
create="$(cat "$ROOT/skills/create-agent-onboarding/SKILL.md")"
compress="$(cat "$ROOT/skills/compress-onboarding/SKILL.md")"
assert_contains "$skill" 'write-evidence' 'update persists durable evidence' || exit 1
assert_contains "$skill" 'Recheck `git rev-parse HEAD` equals the evidenced' 'update rechecks head after evidence' || exit 1
assert_contains "$skill" 'failure or changed `HEAD` leaves state unchanged' 'state remains last' || exit 1
assert_contains "$skill" 'onboarding-validation' 'relevant update records validators' || exit 1
assert_contains "$create" 'initial `state.json` pointer until the Phase 7 validation' 'create keeps state after validation' || exit 1
assert_contains "$create" 'write one compact `onboarding-validation`' 'create writes validation evidence' || exit 1
assert_contains "$compress" '`compression-verification`' 'compression writes evidence' || exit 1
assert_contains "$skill" 'standalone `audit-agent-onboarding` workflow remains read-only' 'audit does not write alone' || exit 1

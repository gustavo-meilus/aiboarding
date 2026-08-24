#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
FIX="$ROOT/tests/fixtures/compression-policy"
skill="$(cat "$ROOT/skills/compress-onboarding/SKILL.md")"
create="$(cat "$ROOT/skills/create-agent-onboarding/SKILL.md")"
update="$(cat "$ROOT/skills/update-agent-onboarding/SKILL.md")"
audit="$(cat "$ROOT/skills/audit-agent-onboarding/SKILL.md")"

section() {
  awk -v heading="$2" '
    $0 == "## " heading { capture=1 }
    capture { print }
    capture && NR > 1 && /^## / && $0 != "## " heading { exit }
  ' "$1" | sed '$ { /^## /d; }'
}

# Canonical sections and off-heading security/destructive blocks stay byte-identical.
for heading in 'Agent Guardrails' 'Escalation - Ask the User When' 'Release procedure' 'Security note'; do
  assert_eq "$(section "$FIX/before.md" "$heading")" "$(section "$FIX/after-default.md" "$heading")" "$heading preserved by default" || exit 1
done
assert_not_contains "$(section "$FIX/after-opted-in.md" 'Escalation - Ask the User When')" 'Ask the user' 'selected opt-in region may be rewritten' || exit 1
for heading in 'Agent Guardrails' 'Release procedure' 'Security note'; do
  assert_eq "$(section "$FIX/before.md" "$heading")" "$(section "$FIX/after-opted-in.md" "$heading")" "$heading remains unchanged without opt-in" || exit 1
done
[ "$(wc -c < "$FIX/after-default.md")" -lt "$(wc -c < "$FIX/before.md")" ] || { echo 'FAIL: ordinary prose was not reduced'; exit 1; }

# Contract is narrow: canonical sections plus complete equivalent instruction blocks.
assert_contains "$skill" 'Agent Guardrails' 'canonical guardrails classified' || exit 1
assert_contains "$skill" 'Escalation - Ask the User When' 'canonical escalation classified' || exit 1
assert_contains "$skill" 'verbatim' 'default preservation stated' || exit 1
assert_contains "$skill" 'full` or `ultra`' 'levels never imply consent' || exit 1
assert_contains "$skill" 'explicit opt-in' 'separate consent required' || exit 1
assert_contains "$skill" 'Do not classify ordinary' 'classification remains narrow' || exit 1
assert_contains "$skill" 'high_consequence_regions' 'receipt evidence recorded' || exit 1
assert_contains "$audit" 'not recorded' 'legacy receipts remain readable' || exit 1
assert_contains "$create" 'following the `compress-onboarding`' 'create delegates policy' || exit 1
assert_contains "$update" 'Follow the `compress-onboarding`' 'update delegates policy' || exit 1
assert_not_contains "$create" 'capped at `lite`' 'create has no conflicting cap' || exit 1
assert_not_contains "$update" 'capped at `lite`' 'update has no conflicting cap' || exit 1

# Receipt fixtures cover preserved, explicitly rewritten, empty, and legacy evidence.
receipts="$(cat "$FIX/receipts.json")"
assert_contains "$receipts" '"outcome":"preserved"' 'preserved receipt fixture' || exit 1
assert_contains "$receipts" '"outcome":"rewritten"' 'rewritten receipt fixture' || exit 1
assert_contains "$receipts" '"explicit_opt_in":true' 'opt-in receipt fixture' || exit 1
assert_contains "$receipts" '"high_consequence_regions":[]' 'empty receipt fixture' || exit 1

bash "$ROOT/tests/tools/test-check-preservation.sh"

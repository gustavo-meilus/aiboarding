#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"; . "$ROOT/tests/lib/assert.sh"
TOOL="$ROOT/templates/tools/verify-onboarding-mutations"; FIX="$ROOT/tests/fixtures/mutations"
bash "$TOOL" "$FIX" validate
out="$(bash "$TOOL" "$FIX" computed)"
assert_contains "$out" 'protected-command|preservation|computed|killed' 'protected command dies mechanically' || exit 1
assert_contains "$out" 'instruction-chain-budget|audit|computed|killed' 'chain cap dies mechanically' || exit 1
set +e; out="$(bash "$TOOL" "$FIX" report 2>&1)"; rc=$?; set -e
assert_eq "$rc" 0 'complete corpus all killed' || exit 1
assert_contains "$out" 'challenge=9/9 syntax-baseline=1/1' 'baseline excluded from challenge score' || exit 1
assert_eq "$out" "$(cat "$FIX/expected-report.txt")" 'report remains stable' || exit 1
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT; cp -R "$FIX" "$tmp/corpus"; head -n 1 "$FIX/inferred-evidence.tsv" > "$tmp/corpus/inferred-evidence.tsv"
set +e; bash "$TOOL" "$tmp/corpus" report >/dev/null 2>&1; rc=$?; set -e
assert_eq "$rc" 1 'missing findings become visible survivors' || exit 1
rm "$tmp/corpus/inferred-evidence.tsv"
set +e; bash "$TOOL" "$tmp/corpus" report >/dev/null 2>&1; rc=$?; set -e
assert_eq "$rc" 2 'missing evidence incomplete' || exit 1
printf 'corpus=stale|audit_skill_revision=test|runtime_model=fixture-model|reviewed_at=2026-08-23\n' > "$tmp/corpus/inferred-evidence.tsv"
set +e; bash "$TOOL" "$tmp/corpus" report >/dev/null 2>&1; rc=$?; set -e
assert_eq "$rc" 2 'stale evidence incomplete' || exit 1
cp -R "$FIX" "$tmp/invalid"; sed -i '2s/|challenge|/||/' "$tmp/invalid/manifest.tsv"
set +e; bash "$TOOL" "$tmp/invalid" validate >/dev/null 2>&1; rc=$?; set -e
assert_eq "$rc" 2 'missing metadata rejected' || exit 1
cp -R "$FIX" "$tmp/duplicate"; sed -i '3s/^guardrail-weakening/verification-removal/' "$tmp/duplicate/manifest.tsv"
set +e; bash "$TOOL" "$tmp/duplicate" validate >/dev/null 2>&1; rc=$?; set -e
assert_eq "$rc" 2 'duplicate IDs rejected' || exit 1
cp -R "$FIX" "$tmp/no-positive"; sed -i '2s#verification-removal/positive#missing#' "$tmp/no-positive/manifest.tsv"
set +e; bash "$TOOL" "$tmp/no-positive" validate >/dev/null 2>&1; rc=$?; set -e
assert_eq "$rc" 2 'missing positive control rejected' || exit 1
cp -R "$FIX" "$tmp/no-category"; sed -i '/runtime-version/d' "$tmp/no-category/manifest.tsv"
set +e; bash "$TOOL" "$tmp/no-category" validate >/dev/null 2>&1; rc=$?; set -e
assert_eq "$rc" 2 'missing required category rejected' || exit 1

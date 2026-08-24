#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
TOOL="$ROOT/templates/tools/audit-onboarding-evidence"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/.claude/rules" "$tmp/nested"
printf '# Root\n' > "$tmp/AGENTS.md"
printf '@AGENTS.md\n<!-- aiboarding-begin:notes -->\n<!-- aiboarding-end:notes -->\n' > "$tmp/CLAUDE.md"
bash "$TOOL" "$tmp"

printf 'missing import\n<!-- aiboarding-begin:notes -->\n' > "$tmp/CLAUDE.md"
set +e
out="$(bash "$TOOL" "$tmp")"; rc=$?
set -e
assert_eq "$rc" 1 'wrapper failure exits 1' || exit 1
assert_contains "$out" 'FAIL|computed|wrapper-integrity|CLAUDE.md:1' 'missing import has stable fields' || exit 1
assert_contains "$out" 'CLAUDE.md:EOF' 'unclosed marker detected' || exit 1

printf '@AGENTS.md\n' > "$tmp/CLAUDE.md"
printf 'x%.0s' {1..24001} > "$tmp/.claude/rules/soft.md"
set +e
out="$(bash "$TOOL" "$tmp")"; rc=$?
set -e
assert_eq "$rc" 0 'soft budget exits 0' || exit 1
assert_contains "$out" 'WARN|computed|size-budget|.claude/rules/soft.md:1' 'soft budget is computed warning' || exit 1
rm "$tmp/.claude/rules/soft.md"

printf 'x%.0s' {1..20000} > "$tmp/AGENTS.md"
printf 'x%.0s' {1..20000} > "$tmp/nested/AGENTS.md"
set +e
out="$(bash "$TOOL" "$tmp")"; rc=$?
set -e
assert_eq "$rc" 1 'strict and chain failures exit 1' || exit 1
assert_contains "$out" 'FAIL|computed|codex-project-doc-budget|nested:1' 'nested chain limit detected' || exit 1
assert_contains "$out" 'chain AGENTS.md (20000 bytes), nested/AGENTS.md (20000 bytes); total 40000 bytes > limit 32768 bytes (Codex default)' 'chain finding has ordered exact evidence' || exit 1

printf '# Root\n`bash scripts/good.sh`\n`npm run good`\n`make good`\n`bash scripts/missing.sh`\n`npm run missing`\n`make missing`\n`run tests`\n' > "$tmp/AGENTS.md"
printf '@AGENTS.md\n' > "$tmp/CLAUDE.md"
mkdir -p "$tmp/scripts"; printf 'ok\n' > "$tmp/scripts/good.sh"
printf '{"scripts":{"good":"true"}}\n' > "$tmp/package.json"
printf 'good:\n\t@true\n' > "$tmp/Makefile"
set +e
out="$(bash "$TOOL" "$tmp")"; rc=$?
set -e
assert_eq "$rc" 1 'missing supported references exit 1' || exit 1
assert_contains "$out" 'missing command path scripts/missing.sh' 'missing path detected' || exit 1
assert_contains "$out" 'missing package script missing' 'missing script detected' || exit 1
assert_contains "$out" 'missing make target missing' 'missing target detected' || exit 1
assert_not_contains "$out" 'run tests' 'ambiguous text ignored' || exit 1

set +e
bash "$TOOL" "$tmp/nope" >/dev/null 2>&1; rc=$?
set -e
assert_eq "$rc" 2 'invalid root exits 2' || exit 1

# Codex project-chain discovery: one non-empty file per directory, root first.
rm -rf "$tmp"/* "$tmp"/.aiboarding
mkdir -p "$tmp/nested" "$tmp/sibling" "$tmp/.aiboarding"
printf 'root' > "$tmp/AGENTS.md"
set +e
out="$(bash "$TOOL" "$tmp")"; rc=$?
set -e
assert_eq "$rc" 0 'root-only chain is within default budget' || exit 1
assert_eq "$out" '' 'root-only chain emits no finding' || exit 1

printf 'override' > "$tmp/nested/AGENTS.override.md"
printf 'inactive' > "$tmp/nested/AGENTS.md"
printf 'fallback' > "$tmp/nested/TEAM.md"
printf '{"codex_project_doc_max_bytes": 10, "project_doc_fallback_filenames": ["TEAM.md"]}\n' > "$tmp/.aiboarding/config.json"
set +e
out="$(bash "$TOOL" "$tmp")"; rc=$?
set -e
assert_eq "$rc" 1 'configured limit fails selected nested chain' || exit 1
assert_contains "$out" 'endpoint nested; chain AGENTS.md (4 bytes), nested/AGENTS.override.md (8 bytes); total 12 bytes > limit 10 bytes (configured)' 'override wins and inactive candidates excluded' || exit 1

: > "$tmp/nested/AGENTS.override.md"
set +e
out="$(bash "$TOOL" "$tmp")"; rc=$?
set -e
assert_contains "$out" 'nested/AGENTS.md (8 bytes)' 'empty override is skipped' || exit 1
assert_not_contains "$out" 'TEAM.md' 'lower fallback inactive when AGENTS exists' || exit 1

rm "$tmp/nested/AGENTS.md"
set +e
out="$(bash "$TOOL" "$tmp")"; rc=$?
set -e
assert_contains "$out" 'nested/TEAM.md (8 bytes)' 'configured fallback selected' || exit 1

printf '12345678901234567890' > "$tmp/sibling/AGENTS.md"
printf '{"strict_max_bytes": 30}\n' > "$tmp/.aiboarding/config.json"
set +e
out="$(bash "$TOOL" "$tmp")"; rc=$?
set -e
assert_eq "$rc" 0 'sibling chains stay below legacy limit independently' || exit 1
assert_eq "$out" '' 'independent sibling bytes are not combined' || exit 1

printf '{"codex_project_doc_max_bytes": "bad"}\n' > "$tmp/.aiboarding/config.json"
set +e
bash "$TOOL" "$tmp" >/dev/null 2>&1; rc=$?
set -e
assert_eq "$rc" 2 'invalid configured limit is operational error' || exit 1

printf '{"codex_project_doc_max_bytes": 1}\n' > "$tmp/.aiboarding/config.json"
set +e
out="$(bash "$TOOL" "$tmp" --codex-project-doc-max-bytes 30)"; rc=$?
set -e
assert_eq "$rc" 0 'explicit limit overrides managed config' || exit 1

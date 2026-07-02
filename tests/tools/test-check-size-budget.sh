#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
TOOL="$ROOT/templates/tools/check-size-budget"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# 1. Within budget: silent, exit 0.
printf '# AGENTS.md\nShort doc.\n' > "$tmp/small.md"
out="$(bash "$TOOL" "$tmp/small.md")"
assert_eq "$out" "" "within budget is silent" || exit 1

# 2. Over the line budget: WARN, exit 0.
: > "$tmp/tall.md"
i=0
while [ "$i" -lt 230 ]; do printf 'line\n' >> "$tmp/tall.md"; i=$((i+1)); done
out="$(bash "$TOOL" "$tmp/tall.md")"
assert_contains "$out" 'WARN' "over line budget warns" || exit 1
assert_contains "$out" '230 lines' "warning names the line count" || exit 1

# 3. Over the byte budget (custom thresholds): WARN, exit 0.
printf 'this line is over twenty bytes\n' > "$tmp/wide.md"
out="$(bash "$TOOL" "$tmp/wide.md" 220 20 32768)"
assert_contains "$out" 'WARN' "over byte budget warns" || exit 1

# 4. Over the strict cap: FAIL on stderr, exit 1.
: > "$tmp/huge.md"
chunk="$(printf 'x%.0s' 1 2 3 4 5 6 7 8 9 10)"   # 10 bytes
i=0
while [ "$i" -lt 4000 ]; do printf '%s' "$chunk" >> "$tmp/huge.md"; i=$((i+1)); done
set +e
err="$(bash "$TOOL" "$tmp/huge.md" 2>&1 >/dev/null)"
rc=$?
set -e
assert_eq "$rc" "1" "over strict cap exits 1" || exit 1
assert_contains "$err" 'project_doc_max_bytes' "failure names the Codex cap" || exit 1

# 5. Missing file: usage error, exit 2.
set +e
bash "$TOOL" "$tmp/nope.md" 2>/dev/null
rc=$?
set -e
assert_eq "$rc" "2" "missing file exits 2" || exit 1

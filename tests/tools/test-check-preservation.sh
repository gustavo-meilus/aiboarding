#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
TOOL="$ROOT/templates/tools/check-preservation"
FIX="$ROOT/tests/fixtures/compression"

# 1. Good compression: prose rewritten, every protected span intact -> exit 0.
out="$(bash "$TOOL" "$FIX/before.md" "$FIX/after-good.md" 2>&1)"
assert_eq "$out" "" "good compression passes silently" || exit 1

# 2. Dropped command flag inside an inline backtick span -> exit 1, span named.
set +e
err="$(bash "$TOOL" "$FIX/before.md" "$FIX/after-bad-cmd.md" 2>&1)"
rc=$?
set -e
assert_eq "$rc" "1" "altered inline command fails" || exit 1
assert_contains "$err" 'inline-code' "failure names the span kind" || exit 1
assert_contains "$err" 'npm run build --workspaces' "failure names the missing span" || exit 1

# 3. Reflowed code fence -> exit 1 as a single code-fence unit.
set +e
err="$(bash "$TOOL" "$FIX/before.md" "$FIX/after-bad-fence.md" 2>&1)"
rc=$?
set -e
assert_eq "$rc" "1" "reflowed code fence fails" || exit 1
assert_contains "$err" 'code-fence' "failure names the fence kind" || exit 1

# 4. URL and path tokens are protected (drop the URL -> fail naming it).
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
grep -v 'localhost:3000' "$FIX/after-good.md" > "$tmp/no-url.md"
set +e
err="$(bash "$TOOL" "$FIX/before.md" "$tmp/no-url.md" 2>&1)"
rc=$?
set -e
assert_eq "$rc" "1" "dropped URL fails" || exit 1
assert_contains "$err" 'https://localhost:3000/dashboard' "failure names the URL" || exit 1

# 5. Identical file trivially passes.
out="$(bash "$TOOL" "$FIX/before.md" "$FIX/before.md" 2>&1)"
assert_eq "$out" "" "identity comparison passes" || exit 1

# 6. Unclosed fence in the source is a usage error (exit 2).
printf '# x\n```bash\nnever closed\n' > "$tmp/unclosed.md"
set +e
bash "$TOOL" "$tmp/unclosed.md" "$FIX/after-good.md" 2>/dev/null
rc=$?
set -e
assert_eq "$rc" "2" "unclosed fence exits 2" || exit 1

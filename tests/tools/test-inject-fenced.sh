#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
TOOL="$ROOT/templates/tools/inject-fenced"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

target="$tmp/CLAUDE.md"
content="$tmp/content.md"
printf '@AGENTS.md\n\nUser-owned notes above the fence.\n' > "$target"
printf -- '- Use plan mode before risky refactors.\n- Run the verification commands before finalizing.\n' > "$content"

# 1. First injection appends a marker-fenced block.
bash "$TOOL" "$target" "claude-notes" "$content"
out="$(cat "$target")"
assert_contains "$out" '<!-- aiboarding-begin:claude-notes -->' "begin marker present" || exit 1
assert_contains "$out" '<!-- aiboarding-end:claude-notes -->' "end marker present" || exit 1
assert_contains "$out" 'Use plan mode before risky refactors.' "content injected" || exit 1
assert_contains "$out" 'User-owned notes above the fence.' "user content preserved" || exit 1

# 2. Idempotency: re-running with identical content leaves the file byte-identical.
before="$(cat "$target")"
bash "$TOOL" "$target" "claude-notes" "$content"
after="$(cat "$target")"
assert_eq "$after" "$before" "re-run with same content is byte-identical" || exit 1

# 3. Updating content touches only the fenced region.
printf -- '- Updated single note.\n' > "$content"
bash "$TOOL" "$target" "claude-notes" "$content"
out="$(cat "$target")"
assert_contains "$out" 'Updated single note.' "updated content present" || exit 1
assert_not_contains "$out" 'Use plan mode before risky refactors.' "old content replaced" || exit 1
assert_contains "$out" 'User-owned notes above the fence.' "user content still preserved" || exit 1
head_before_block="${out%%<!-- aiboarding-begin:claude-notes -->*}"
assert_eq "$head_before_block" '@AGENTS.md

User-owned notes above the fence.

' "content before the fence untouched" || exit 1

# 4. Removal strips the block and markers, keeps user content.
bash "$TOOL" "$target" "claude-notes" --remove
out="$(cat "$target")"
assert_not_contains "$out" 'aiboarding-begin' "begin marker removed" || exit 1
assert_not_contains "$out" 'aiboarding-end' "end marker removed" || exit 1
assert_not_contains "$out" 'Updated single note.' "block content removed" || exit 1
assert_contains "$out" 'User-owned notes above the fence.' "user content survives removal" || exit 1

# 5. Injecting into a missing file creates it with only the block.
missing="$tmp/new-file.md"
printf 'pointer to AGENTS.md\n' > "$content"
bash "$TOOL" "$missing" "adapter" "$content"
out="$(cat "$missing")"
assert_eq "$out" '<!-- aiboarding-begin:adapter -->
pointer to AGENTS.md
<!-- aiboarding-end:adapter -->' "missing file created with only the block" || exit 1

# 6. Removing from a file without the block is a no-op.
printf 'plain file\n' > "$tmp/plain.md"
bash "$TOOL" "$tmp/plain.md" "nope" --remove
assert_eq "$(cat "$tmp/plain.md")" 'plain file' "remove is a no-op without the block" || exit 1

# 7. Distinct block ids do not interfere.
bash "$TOOL" "$tmp/plain.md" "a" "$content"
printf 'second block\n' > "$content"
bash "$TOOL" "$tmp/plain.md" "b" "$content"
out="$(cat "$tmp/plain.md")"
assert_contains "$out" 'aiboarding-begin:a' "block a present" || exit 1
assert_contains "$out" 'aiboarding-begin:b' "block b present" || exit 1
bash "$TOOL" "$tmp/plain.md" "a" --remove
out="$(cat "$tmp/plain.md")"
assert_not_contains "$out" 'aiboarding-begin:a -->' "block a removed" || exit 1
assert_contains "$out" 'second block' "block b untouched by removing a" || exit 1

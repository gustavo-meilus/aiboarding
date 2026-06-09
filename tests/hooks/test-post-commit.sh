#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
HOOK="$ROOT/templates/hooks/post-commit"

# Build a temp git repo with an AIBOARDING.md whose last_synced_commit is stale.
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
git -C "$tmp" init -q
git -C "$tmp" config user.email t@t.t
git -C "$tmp" config user.name t
printf 'x\n' > "$tmp/file.txt"
git -C "$tmp" add file.txt
git -C "$tmp" commit -q -m one
printf -- '---\naiboarding_version: 1\ngenerated: 2026-05-29\nlast_synced_commit: deadbeef\n---\n# 1. Engineering Basics\n' > "$tmp/AIBOARDING.md"

# Stale: last_synced_commit (deadbeef) != HEAD -> drift nudge.
out="$(CLAUDE_PROJECT_DIR="$tmp" bash "$HOOK")"
assert_contains "$out" '"hookEventName":"PostToolUse"' "emits PostToolUse on drift" || exit 1
assert_contains "$out" 'update-aiboarding' "nudge names update-aiboarding" || exit 1
  # "deadbeef" is the literal last_synced_commit written into AIBOARDING.md above
assert_contains "$out" 'deadbeef..HEAD' "nudge names the commit range" || exit 1

# In sync: set last_synced_commit to real HEAD -> no output.
head="$(git -C "$tmp" rev-parse HEAD)"
printf -- '---\naiboarding_version: 1\ngenerated: 2026-05-29\nlast_synced_commit: %s\n---\n' "$head" > "$tmp/AIBOARDING.md"
out_sync="$(CLAUDE_PROJECT_DIR="$tmp" bash "$HOOK")"
assert_eq "$out_sync" "" "no output when in sync" || exit 1

# No doc -> no output.
rm "$tmp/AIBOARDING.md"
out_nodoc="$(CLAUDE_PROJECT_DIR="$tmp" bash "$HOOK")"
assert_eq "$out_nodoc" "" "no output when doc missing" || exit 1

# --- Range filter: doc-only commits must NOT nudge -------------------------

# Fresh repo: commit one (code), then a doc-only commit whose pointer lags HEAD.
tmp2="$(mktemp -d)"
trap 'rm -rf "$tmp" "$tmp2"' EXIT
git -C "$tmp2" init -q
git -C "$tmp2" config user.email t@t.t
git -C "$tmp2" config user.name t
printf 'x\n' > "$tmp2/file.txt"
git -C "$tmp2" add file.txt
git -C "$tmp2" commit -q -m one
base="$(git -C "$tmp2" rev-parse HEAD)"
# Doc-only commit two; pointer still lags at `base`.
printf -- '---\naiboarding_version: 1\ngenerated: 2026-05-29\nlast_synced_commit: %s\n---\n# 1. Engineering Basics\n' "$base" > "$tmp2/AIBOARDING.md"
git -C "$tmp2" add AIBOARDING.md
git -C "$tmp2" commit -q -m "docs: add doc"

# (a) single doc-only commit in range -> suppress.
out_a="$(CLAUDE_PROJECT_DIR="$tmp2" bash "$HOOK")"
assert_eq "$out_a" "" "no nudge when range is doc-only (single commit)" || exit 1

# (b) chain of two doc-only commits in range -> still suppress.
printf -- '---\naiboarding_version: 1\ngenerated: 2026-05-29\nlast_synced_commit: %s\n---\n# 1. Engineering Basics\n\nedited\n' "$base" > "$tmp2/AIBOARDING.md"
git -C "$tmp2" add AIBOARDING.md
git -C "$tmp2" commit -q -m "docs: advance sync pointer"
out_b="$(CLAUDE_PROJECT_DIR="$tmp2" bash "$HOOK")"
assert_eq "$out_b" "" "no nudge when range is doc-only (two commits)" || exit 1

# (c) doc + code commit in range -> nudge.
printf 'y\n' > "$tmp2/file.txt"
git -C "$tmp2" add file.txt
git -C "$tmp2" commit -q -m "feat: code change"
out_c="$(CLAUDE_PROJECT_DIR="$tmp2" bash "$HOOK")"
assert_contains "$out_c" '"hookEventName":"PostToolUse"' "nudge when a code commit is in range" || exit 1

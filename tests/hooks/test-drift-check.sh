#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
HOOK="$ROOT/templates/hooks/drift-check"

# Helper: fresh scratch git repo with one code commit.
new_repo() {
  local dir="$1"
  git -C "$dir" init -q
  git -C "$dir" config user.email t@t.t
  git -C "$dir" config user.name t
  printf 'x\n' > "$dir/file.txt"
  git -C "$dir" add file.txt
  git -C "$dir" commit -q -m one
}

# Helper: write a modern state.json with the given pointer.
write_state() {
  local dir="$1" ptr="$2"
  mkdir -p "$dir/.aiboarding"
  printf -- '{\n  "aiboarding_version": 2,\n  "last_synced_commit": "%s"\n}\n' "$ptr" > "$dir/.aiboarding/state.json"
}

run_hook() {
  CLAUDE_PROJECT_DIR="$1" bash "$HOOK" < /dev/null
}

# --- Modern layout: state.json sidecar ------------------------------------

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
new_repo "$tmp"
head="$(git -C "$tmp" rev-parse HEAD)"

# 1. In sync: pointer == HEAD -> silent.
write_state "$tmp" "$head"
out="$(run_hook "$tmp")"
assert_eq "$out" "" "no output when state pointer is in sync" || exit 1

# 2. Stale pointer with a code commit in range -> nudge naming the new skill.
base="$head"
printf 'y\n' > "$tmp/file.txt"
git -C "$tmp" add file.txt
git -C "$tmp" commit -q -m "feat: code change"
out="$(run_hook "$tmp")"
assert_contains "$out" '"hookEventName":"PostToolUse"' "emits PostToolUse on drift" || exit 1
assert_contains "$out" 'update-agent-onboarding' "nudge names update-agent-onboarding" || exit 1
assert_contains "$out" "$base..HEAD" "nudge names the commit range" || exit 1

# 3. Range touching only onboarding files -> suppressed.
head="$(git -C "$tmp" rev-parse HEAD)"
write_state "$tmp" "$head"
printf '# AGENTS.md\nupdated\n' > "$tmp/AGENTS.md"
git -C "$tmp" add AGENTS.md .aiboarding/state.json
git -C "$tmp" commit -q -m "docs: onboarding update"
out="$(run_hook "$tmp")"
assert_eq "$out" "" "no nudge when range touches only AGENTS.md and .aiboarding/" || exit 1

# 4. Config ignored_paths respected (README-only range stays silent).
printf -- '{\n  "ignored_paths": [\n    "README.md"\n  ]\n}\n' > "$tmp/.aiboarding/config.json"
printf 'readme\n' > "$tmp/README.md"
git -C "$tmp" add README.md
git -C "$tmp" commit -q -m "docs: readme"
out="$(run_hook "$tmp")"
assert_eq "$out" "" "no nudge when range matches config ignored_paths" || exit 1

# 5. Mixed range (ignored + code) -> nudge.
printf 'z\n' > "$tmp/file.txt"
git -C "$tmp" add file.txt
git -C "$tmp" commit -q -m "feat: more code"
out="$(run_hook "$tmp")"
assert_contains "$out" '"hookEventName":"PostToolUse"' "nudge when a code commit is in range" || exit 1

# 6. Empty pointer -> nudge (repair signal).
write_state "$tmp" ""
out="$(run_hook "$tmp")"
assert_contains "$out" '"hookEventName":"PostToolUse"' "nudge when pointer is empty" || exit 1

# 7. Bogus pointer (git failure) -> nudge (drift-on-uncertainty).
write_state "$tmp" "deadbeefdeadbeef"
out="$(run_hook "$tmp")"
assert_contains "$out" '"hookEventName":"PostToolUse"' "nudge when git cannot resolve the pointer" || exit 1

# --- Stdin self-gate --------------------------------------------------------

# 8. Piped non-git PostToolUse JSON -> silent even though state is stale.
out="$(printf '{"tool_name":"Bash","tool_input":{"command":"ls -la"}}' | CLAUDE_PROJECT_DIR="$tmp" bash "$HOOK")"
assert_eq "$out" "" "stdin gate: non-git command exits silently" || exit 1

# 9. Piped git-command JSON -> evaluates and nudges.
out="$(printf '{"tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' | CLAUDE_PROJECT_DIR="$tmp" bash "$HOOK")"
assert_contains "$out" '"hookEventName":"PostToolUse"' "stdin gate: git command evaluates" || exit 1

# 10. Empty stdin (redirected /dev/null) -> still evaluates (compat).
out="$(run_hook "$tmp")"
assert_contains "$out" '"hookEventName":"PostToolUse"' "empty stdin still evaluates" || exit 1

# --- No layout at all -------------------------------------------------------

# 11. Neither state.json nor AIBOARDING.md -> silent.
tmp_none="$(mktemp -d)"
trap 'rm -rf "$tmp" "$tmp_none"' EXIT
new_repo "$tmp_none"
out="$(run_hook "$tmp_none")"
assert_eq "$out" "" "no output when no aiboarding layout exists" || exit 1

# --- Legacy layout: AIBOARDING.md frontmatter pointer (v0.2.0 behavior) -----

tmp2="$(mktemp -d)"
trap 'rm -rf "$tmp" "$tmp_none" "$tmp2"' EXIT
new_repo "$tmp2"
base="$(git -C "$tmp2" rev-parse HEAD)"

# 12. Legacy stale pointer -> nudge names migrate-aiboarding.
printf -- '---\naiboarding_version: 1\ngenerated: 2026-05-29\nlast_synced_commit: deadbeef\n---\n# 1. Engineering Basics\n' > "$tmp2/AIBOARDING.md"
out="$(run_hook "$tmp2")"
assert_contains "$out" '"hookEventName":"PostToolUse"' "legacy: emits PostToolUse on drift" || exit 1
assert_contains "$out" 'migrate-aiboarding' "legacy: nudge names migrate-aiboarding" || exit 1

# 13. Legacy in sync -> silent.
printf -- '---\naiboarding_version: 1\ngenerated: 2026-05-29\nlast_synced_commit: %s\n---\n# 1. Engineering Basics\n' "$base" > "$tmp2/AIBOARDING.md"
out="$(run_hook "$tmp2")"
assert_eq "$out" "" "legacy: no output when in sync" || exit 1

# 14. Legacy doc-only range -> suppressed (v0.2.0 issue-#1 fix preserved).
git -C "$tmp2" add AIBOARDING.md
git -C "$tmp2" commit -q -m "docs: add doc"
out="$(run_hook "$tmp2")"
assert_eq "$out" "" "legacy: no nudge when range is doc-only (single commit)" || exit 1

# 15. Legacy chain of two doc-only commits -> still suppressed.
printf -- '---\naiboarding_version: 1\ngenerated: 2026-05-29\nlast_synced_commit: %s\n---\n# 1. Engineering Basics\n\nedited\n' "$base" > "$tmp2/AIBOARDING.md"
git -C "$tmp2" add AIBOARDING.md
git -C "$tmp2" commit -q -m "docs: advance sync pointer"
out="$(run_hook "$tmp2")"
assert_eq "$out" "" "legacy: no nudge when range is doc-only (two commits)" || exit 1

# 16. Legacy doc + code commit in range -> nudge.
printf 'y\n' > "$tmp2/file.txt"
git -C "$tmp2" add file.txt
git -C "$tmp2" commit -q -m "feat: code change"
out="$(run_hook "$tmp2")"
assert_contains "$out" '"hookEventName":"PostToolUse"' "legacy: nudge when a code commit is in range" || exit 1

# 17. Legacy empty pointer -> nudge as a repair signal.
printf -- '---\naiboarding_version: 1\ngenerated: 2026-05-29\nlast_synced_commit:\n---\n# 1. Engineering Basics\n' > "$tmp2/AIBOARDING.md"
out="$(run_hook "$tmp2")"
assert_contains "$out" '"hookEventName":"PostToolUse"' "legacy: nudge when last_synced_commit is empty" || exit 1

# 18. Modern state.json wins over a lingering legacy doc.
tmp3="$(mktemp -d)"
trap 'rm -rf "$tmp" "$tmp_none" "$tmp2" "$tmp3"' EXIT
new_repo "$tmp3"
head3="$(git -C "$tmp3" rev-parse HEAD)"
write_state "$tmp3" "$head3"
printf -- '---\naiboarding_version: 1\ngenerated: 2026-05-29\nlast_synced_commit: deadbeef\n---\n# 1. Engineering Basics\n' > "$tmp3/AIBOARDING.md"
out="$(run_hook "$tmp3")"
assert_eq "$out" "" "state.json takes precedence over legacy AIBOARDING.md" || exit 1

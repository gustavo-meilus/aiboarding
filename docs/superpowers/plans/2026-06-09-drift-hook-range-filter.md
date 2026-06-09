# Drift-hook range filter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stop the `update-aiboarding` self-referential drift loop by suppressing the post-commit nudge when every commit in `last_synced_commit..HEAD` touches only `AIBOARDING.md`.

**Architecture:** Add a range-content check to `templates/hooks/post-commit`. After the existing empty-pointer and in-sync guards, compute `git diff --name-only last..HEAD`; suppress the nudge only when the result is non-empty and every path is `AIBOARDING.md`. Any git failure or non-doc path falls through to the existing nudge (safe default).

**Tech Stack:** Bash (Git Bash compatible), POSIX git, the repo's no-dep shell test harness (`tests/lib/assert.sh`, `tests/run.sh`).

**Spec:** `docs/superpowers/specs/2026-06-09-drift-hook-range-filter-design.md`

---

### Task 1: Range-filter the drift nudge

**Files:**
- Modify: `templates/hooks/post-commit` (the `if [ "$last" != "$head_sha" ]` block, lines 18-21)
- Test: `tests/hooks/test-post-commit.sh`

- [ ] **Step 1: Write the failing tests**

Append these blocks to the end of `tests/hooks/test-post-commit.sh` (after the existing "No doc -> no output" case at line 34). They build real commits so `git diff --name-only` resolves a real range.

```bash

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
```

- [ ] **Step 2: Run tests to verify the new cases fail**

Run: `bash tests/hooks/test-post-commit.sh`
Expected: FAIL at "no nudge when range is doc-only (single commit)" — the current hook nudges on any `last != HEAD`, so it emits PostToolUse instead of empty output.

- [ ] **Step 3: Implement the range filter**

In `templates/hooks/post-commit`, replace the final nudge block (lines 16-21, the comment plus the `if [ "$last" != "$head_sha" ]` ... `fi`) with:

```bash
# Decide whether to nudge.
# - Empty/absent last_synced_commit (malformed or never-synced doc): nudge on
#   purpose, prompting the user to run update-aiboarding to repair the pointer.
# - last == HEAD: in sync, stay silent.
# - Otherwise inspect the range: if every changed file is AIBOARDING.md itself
#   (the no-op pointer-advance and content-patch commits), suppress — no real
#   content moved. Any git failure (e.g. a rebased-away pointer) or non-doc path
#   falls through to a nudge, matching the drift-on-uncertainty stance.
nudge=0
if [ -z "$last" ]; then
  nudge=1
elif [ "$last" != "$head_sha" ]; then
  changed="$(git -C "$PROJECT_DIR" diff --name-only "$last"..HEAD 2>/dev/null)" || changed=""
  if [ -z "$changed" ]; then
    nudge=1
  else
    while IFS= read -r f; do
      [ "$f" = "AIBOARDING.md" ] || { nudge=1; break; }
    done <<EOF
$changed
EOF
  fi
fi

if [ "$nudge" -eq 1 ]; then
  raw="$(printf '<aiboarding-drift>Commits have landed since AIBOARDING.md was last synced (%s..HEAD). Run the update-aiboarding skill to triage whether the doc needs updating.</aiboarding-drift>' "$last")"
  emit_cc_context "PostToolUse" "$raw"
fi
exit 0
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `bash tests/hooks/test-post-commit.sh`
Expected: no output and exit 0 (all assertions pass — existing deadbeef/in-sync/no-doc cases plus new (a)/(b)/(c)).

Note: the existing first case (`last_synced_commit: deadbeef`) covers edge (d) — `git diff --name-only deadbeef..HEAD` fails, `changed` is empty, so the hook nudges, as before.

- [ ] **Step 5: Run the full hook test suite**

Run: `bash tests/run.sh`
Expected: all hook test files pass, exit 0.

- [ ] **Step 6: Commit**

```bash
git add templates/hooks/post-commit tests/hooks/test-post-commit.sh
git commit -m "fix: suppress drift nudge when range touches only AIBOARDING.md (#1)"
```

---

## Self-Review

- **Spec coverage:** Logic steps 1-3 → Task 1 Step 3. Edge table rows: doc-only (a/b), doc+code (c), `last` empty (existing in-sync/empty handling + Step 3 branch), `last==HEAD` (existing test line 28), bad sha (existing deadbeef test line 19). All covered.
- **Placeholders:** none — full hook block and full test code shown.
- **Type/name consistency:** `nudge`, `changed`, `last`, `head_sha`, `PROJECT_DIR`, `raw`, `emit_cc_context` all match `_lib` and the existing hook.

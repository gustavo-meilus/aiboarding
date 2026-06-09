# Drift-hook range filter — design

Fixes [issue #1](https://github.com/gustavo-meilus/aiboarding/issues/1): the
`update-aiboarding` no-op pointer-advance creates a self-referential loop. The
`last_synced_commit` pointer lives inside the tracked `AIBOARDING.md`, so every
commit that advances it is itself a new commit that pushes HEAD past the pointer
— the post-commit drift hook then fires again, indefinitely.

## Root cause

The pointer is mutable sync state stored as committed doc content. Writing the
pointer to its own commit hash is impossible (the hash does not exist until the
commit lands), so the pointer always lags HEAD by exactly the commit that wrote
it, and the hook re-nudges on that lone commit forever.

## Approach

Filter the drift nudge by **what changed** in the range, not by commit message.
The hook suppresses the nudge when every commit in `last_synced_commit..HEAD`
touches only `AIBOARDING.md`. This catches both the no-op pointer-advance commit
and the content-patch commit in one rule, with no dependence on commit-message
discipline.

Scope is limited to `templates/hooks/post-commit` plus regression tests. The
`update-aiboarding` skill is unchanged: the no-op branch still advances the
pointer and lands one marker commit — that commit is now silently absorbed
instead of re-nudging.

## Logic (`templates/hooks/post-commit`)

After computing `last` and `head_sha`, before emitting:

1. **Existing guards, unchanged:** `last` empty → nudge (repair signal);
   `last == head_sha` → silent.
2. **New range check:**
   `changed="$(git -C "$PROJECT_DIR" diff --name-only "$last"..HEAD 2>/dev/null)"`
   - If the git call fails (e.g. `last` sha is gone after a rebase), fall
     through to **nudge** — the safe default, consistent with the existing
     drift-on-uncertainty stance.
3. If `changed` is non-empty and **every line equals `AIBOARDING.md`** →
   suppress (no nudge). Otherwise → nudge with the existing message.

The doc filename compared is the repo-root-relative `AIBOARDING.md`, matching
`git diff --name-only` output and `resolve_doc_path`.

## Edge cases

| Range contents | Result |
|---|---|
| only AIBOARDING.md commit(s) | suppress |
| AIBOARDING.md + a code commit | nudge (code changed) |
| doc commit touching doc + other files | nudge |
| `last` empty | nudge (repair) |
| `last == HEAD` | silent (existing) |
| `last` sha missing / git fails | nudge (safe default) |

## Testing (`tests/hooks/test-post-commit.sh`)

Add cases, keeping the existing empty-last and `last == HEAD` cases:

- (a) single doc-only commit in range → no output
- (b) chain of two doc-only commits → no output
- (c) doc + code commit in range → drift output emitted
- (d) bad/missing `last` sha → drift output emitted

## Non-goals

- No change to the `update-aiboarding` skill or its commit behavior.
- No move of sync state out of the tracked doc (sidecar approach rejected to
  preserve cross-clone sync sharing).
- No new commit-message convention.

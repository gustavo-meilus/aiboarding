# Design Spec: `update-aiboarding`

## Overview
`update-aiboarding` keeps `AIBOARDING.md` current as the project evolves. It is a
**hook (deterministic trigger) plus a skill (triage + update reasoning)**. The hook
detects that commits have landed since the document was last reconciled; the skill
judges whether those commits touch the document's scope and, if so, patches the
affected sections.

> **Umbrella:** Shared contracts (document schema, hook layout, drift tracking) are
> defined in [`2026-05-29-aiboarding-architecture.md`](./2026-05-29-aiboarding-architecture.md).
> This spec implements the `PostToolUse[git commit]` row of that hook table and the
> drift-detection flow.

## Hook: `PostToolUse[git commit]` — drift nudge
* **Matcher:** `PostToolUse` on `Bash` where the command contains `git commit`.
* **Script (`post-commit`):** thin and deterministic. Reads `last_synced_commit` from the
  `AIBOARDING.md` frontmatter and compares it to `HEAD`.
  * If equal (or `AIBOARDING.md` absent): no-op, exit `0`.
  * If different: emit context nudging the agent to run the `update-aiboarding` triage
    skill, naming the commit range `<last_synced_commit>..HEAD`.
* **No judgment in the hook.** Significance is a reasoning call and belongs to the skill;
  the hook only signals "commits have landed since last sync." The skill's triage is the
  debounce — it is cheap and may immediately conclude no-op.
* Uses the same polyglot `run-hook.cmd` wrapper and committed-script layout as
  `sync-aiboarding` (see that spec). Installed by `create-aiboarding` Phase 6.

## Skill: triage
When invoked, the skill:
1. **Gathers the delta.** Runs `git diff <last_synced_commit>..HEAD` and reflects on the
   current conversation (the "chat log" is already in the agent's context — no file access
   needed; after compaction it is the available summary).
2. **Classifies scope impact.** Decides whether the delta touches any section of
   `AIBOARDING.md`:
   * Engineering Basics (stack/build/test/run changed?)
   * Domain & Business Logic (new concepts, changed behavior?)
   * AI-Specific Context (new gotchas/failure modes/guardrails?)
3. **Branches:**
   * **No relevant change → no-op.** Advance `last_synced_commit` to `HEAD` in the
     frontmatter **without user approval** and without rewriting body content. This stops
     the hook from re-nudging. (Auto-advance keeps friction low.)
   * **Relevant change → targeted-delta patch** (below).

## Update pass: targeted-delta patch
The update reuses `create-aiboarding`'s machinery but **scoped to the affected sections
only** — it does not re-grill the whole project.

1. **Scoped grill.** Ask the user focused questions about *only* the changed scope, in the
   same relentless one-at-a-time style as `create-aiboarding` Phase 1/Phase 3, seeded by
   the diff. Skip sections the delta does not touch.
2. **Synthesize.** Re-draft only the affected sections, merging verified diff findings with
   the user's answers. Untouched sections are left byte-for-byte intact.
3. **Caveman compression.** Run the Phase 5 caveman pass on the re-drafted sections only,
   preserving the document's existing density and structure.
4. **Advance frontmatter.** Set `last_synced_commit` to `HEAD`.
5. **Approval gate.** Present the patched sections (a diff against the prior `AIBOARDING.md`)
   to the user for approval before writing. Content changes always require approval; only
   the no-op pointer advance is automatic.

## Out of Scope
* Initial document generation and hook installation (owned by `create-aiboarding`).
* Context injection into agents (owned by `sync-aiboarding`).

## Verification
* **No-op path:** commit a change outside the doc's scope (e.g. a typo fix); confirm the
  triage advances `last_synced_commit` silently and rewrites no body content.
* **Patch path:** commit a scope-relevant change (e.g. a new dependency or domain concept);
  confirm the scoped grill fires, only affected sections change, and the user approval gate
  appears before write.
* **Hook trigger:** confirm `git commit` fires the nudge only when `HEAD != last_synced_commit`.
* **Idempotency:** re-running triage with no new commits is a clean no-op.

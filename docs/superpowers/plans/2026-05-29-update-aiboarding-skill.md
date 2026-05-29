# update-aiboarding Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Author the `update-aiboarding` skill that triages whether commits since the last sync touch `AIBOARDING.md`'s scope, then either silently advances the drift pointer or runs a targeted-delta patch.

**Architecture:** A prose `SKILL.md` following superpowers conventions. The deterministic trigger (the `post-commit` drift hook) already ships in Plan 1; this skill is the reasoning half. It reads `git diff <last_synced_commit>..HEAD` plus the current conversation, classifies scope impact, and branches: no-op → auto-advance `last_synced_commit`; relevant → scoped grill + re-draft + caveman the affected sections only, gated on user approval.

**Tech Stack:** Claude Code skill (`SKILL.md` + YAML frontmatter), markdown. Depends on the `caveman` skill (Phase 5 reuse) and the `create-aiboarding` grilling/synthesis style.

**Spec:** `docs/superpowers/specs/2026-05-29-update-aiboarding-design.md`

> **Note on TDD:** Prose skill; no red-green loop. Each task: write the section → verify against writing-skills + the spec → commit. Use `superpowers:writing-skills` while authoring.

---

## File Structure

- `skills/update-aiboarding/SKILL.md` — the skill: frontmatter + triage + branch logic.

Single self-contained file. The `post-commit` hook that invokes it lives in `templates/hooks/` from Plan 1.

---

## Task 1: Skill scaffold + triage

**Files:**
- Create: `skills/update-aiboarding/SKILL.md`

- [ ] **Step 1: Write frontmatter + triage section**

Create `skills/update-aiboarding/SKILL.md`:

```markdown
---
name: update-aiboarding
description: Use when commits have landed since AIBOARDING.md was last synced (the post-commit drift hook nudges for this), or the user asks to refresh the onboarding doc. Triages whether the change touches the doc's scope and patches only the affected sections.
---

# Updating AIBOARDING.md

Keep `AIBOARDING.md` current as the project evolves, without re-grilling the whole repo.

**Announce at start:** "Using update-aiboarding to triage doc drift."

## Triage
1. **Gather the delta.** Read `last_synced_commit` from the `AIBOARDING.md` frontmatter.
   Run `git diff <last_synced_commit>..HEAD`. Reflect on the current conversation — it is
   the "chat log" and is already in your context (after compaction, use the summary).
2. **Classify scope impact.** Decide whether the delta touches any section:
   - Engineering Basics — stack/build/test/run changed?
   - Domain & Business Logic — new concepts or changed behavior?
   - AI-Specific Context — new gotchas, failure modes, or guardrails?
3. **Branch:** no relevant change → No-op (below). Relevant change → Targeted-delta patch.
```

- [ ] **Step 2: Verify triggering**

Use `superpowers:writing-skills`: confirm the `description` is "Use when…", names the drift-hook nudge and explicit-ask triggers, and `name` matches the directory. Confirm the triage reads `last_synced_commit` exactly as Plan 1's `read_frontmatter` writes/reads it.

- [ ] **Step 3: Commit**

```bash
git add skills/update-aiboarding/SKILL.md
git commit -m "feat: scaffold update-aiboarding skill with triage logic"
```

---

## Task 2: No-op path (auto-advance)

**Files:**
- Modify: `skills/update-aiboarding/SKILL.md`

- [ ] **Step 1: Append the no-op branch**

Append to `skills/update-aiboarding/SKILL.md`:

```markdown
## No-op: nothing relevant changed
If triage finds no scope-relevant change:
- Advance `last_synced_commit` in the frontmatter to the current `git rev-parse HEAD`.
- Do **not** rewrite any body content. Do **not** ask the user — this advance is automatic
  (it only stops the drift hook from re-nudging on the same commits).
- Briefly report: "No doc-relevant changes in <range>; advanced sync pointer."
```

- [ ] **Step 2: Verify**

Confirm the no-op only edits frontmatter `last_synced_commit`, requires no approval, and leaves body bytes untouched — matching the spec's "auto-advance, no approval" decision.

- [ ] **Step 3: Commit**

```bash
git add skills/update-aiboarding/SKILL.md
git commit -m "feat: add update-aiboarding no-op auto-advance branch"
```

---

## Task 3: Targeted-delta patch path

**Files:**
- Modify: `skills/update-aiboarding/SKILL.md`

- [ ] **Step 1: Append the patch branch**

Append to `skills/update-aiboarding/SKILL.md`:

```markdown
## Targeted-delta patch: scope changed
Reuse create-aiboarding's machinery, scoped to the affected sections only.

1. **Scoped grill.** Ask focused, one-at-a-time questions about ONLY the changed scope,
   seeded by the diff, in the same relentless style as create-aiboarding. Skip sections
   the delta does not touch.
2. **Synthesize.** Re-draft only the affected sections, merging verified diff findings with
   the user's answers. Leave untouched sections byte-for-byte intact.
3. **Compress.** Run the `caveman` skill's compression on the re-drafted sections only,
   preserving existing density, structure, and code blocks.
4. **Advance frontmatter.** Set `last_synced_commit` to the current `git rev-parse HEAD`.
5. **Approval gate.** Show the user a diff of the patched sections against the prior
   `AIBOARDING.md`. Content changes ALWAYS require approval before writing. Only the no-op
   pointer advance is automatic.
```

- [ ] **Step 2: Verify**

Confirm: only affected sections change (untouched left intact), caveman runs on the re-draft, frontmatter advances, and the approval gate precedes any content write. Cross-check that the grilling style references create-aiboarding rather than redefining it (DRY).

- [ ] **Step 3: Commit**

```bash
git add skills/update-aiboarding/SKILL.md
git commit -m "feat: add update-aiboarding targeted-delta patch branch"
```

---

## Task 4: End-to-end verification

**Files:** none (manual verification)

- [ ] **Step 1: No-op scenario**

In a scratch repo with an installed `AIBOARDING.md`, make a scope-irrelevant commit (e.g. fix
a typo in a code comment). Invoke the skill. Confirm: `last_synced_commit` advances to `HEAD`,
no body content changes, no approval prompt, and a brief report is shown.

- [ ] **Step 2: Patch scenario**

Make a scope-relevant commit (e.g. add a new dependency or a new domain concept). Invoke the
skill. Confirm: a scoped grill fires for only the affected section(s), untouched sections are
unchanged, the re-draft is caveman-compressed, the approval gate appears before write, and
`last_synced_commit` advances after approval.

- [ ] **Step 3: Hook-loop sanity**

After either path, run `git commit` again with no further changes and confirm the `post-commit`
hook stays silent (pointer is current) — verifying the loop closes.

- [ ] **Step 4: Commit any fixes**

```bash
git add -A
git commit -m "fix: address update-aiboarding end-to-end verification findings"
```

---

## Self-Review

**Spec coverage:** Hook trigger linkage (post-commit nudge) → Task 1 frontmatter description; triage gather+classify → Task 1; no-op auto-advance without approval → Task 2; targeted-delta patch (scoped grill, synthesize affected only, caveman, advance pointer, approval gate) → Task 3; verification scenarios → Task 4. ✓

**Placeholder scan:** No TBD/TODO; every branch has concrete steps.

**Consistency:** `last_synced_commit` read/advanced here matches Plan 1's `read_frontmatter`/`post-commit` and Plan 2's create frontmatter. The patch path reuses create-aiboarding's grill/synthesize/caveman rather than redefining them (DRY), consistent with the spec's "targeted-delta patch" decision. The `post-commit` hook that triggers this skill is owned by Plan 1; this plan does not redefine it.

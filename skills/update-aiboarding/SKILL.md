---
name: update-aiboarding
description: Use when commits have landed since AIBOARDING.md was last synced (the post-commit drift hook nudges for this), or the user asks to refresh the onboarding doc. Triages whether the change touches the doc's scope and patches only the affected sections.
---

# Updating AIBOARDING.md

Keep `AIBOARDING.md` current as the project evolves, without re-grilling the whole repo.

**Announce at start:** "Using update-aiboarding to triage doc drift."

## Triage
**If `last_synced_commit` is missing or empty**, the doc was never properly synced (the
drift hook fires on an empty pointer as a repair signal). Do NOT take the No-op branch —
skip the diff shortcut and go straight to the Targeted-delta patch for a full
re-validation of all three sections.

1. **Gather the delta.** Read `last_synced_commit` from the `AIBOARDING.md` frontmatter.
   Run `git diff <last_synced_commit>..HEAD`. Reflect on the current conversation — it is
   the "chat log" and is already in your context (after compaction, use the summary).
2. **Classify scope impact.** Decide whether the delta touches any section:
   - `# 1. Engineering Basics` — stack/build/test/run changed?
   - `# 2. Domain & Business Logic` — new concepts or changed behavior?
   - `# 3. AI-Specific Context` — new gotchas, failure modes, or guardrails?
3. **Branch:** no relevant change → No-op (below). Relevant change → Targeted-delta patch.

## No-op: nothing relevant changed
If triage finds no scope-relevant change:
- Advance `last_synced_commit` in the frontmatter to the current `git rev-parse HEAD`.
- Do **not** rewrite any body content. Do **not** ask the user — this advance is automatic
  (it only stops the drift hook from re-nudging on the same commits).
- Briefly report: "No doc-relevant changes in <range>; advanced sync pointer."

## Targeted-delta patch: scope changed
Reuse create-aiboarding's Phases 1–3 (background crawl + grilling style, architectural
interrogation, reconciliation), scoped to the affected sections only.

1. **Scoped grill.** Ask focused, one-at-a-time questions about ONLY the changed scope,
   seeded by the diff, using the relentless one-question-at-a-time style from
   create-aiboarding's Phases 1–3. Skip sections the delta does not touch.
2. **Synthesize.** Re-draft only the affected sections (use the exact H1 heading text from
   the existing doc — `# 1. Engineering Basics`, `# 2. Domain & Business Logic`,
   `# 3. AI-Specific Context` — to avoid duplicate headings), merging verified diff
   findings with the user's answers. Leave untouched sections byte-for-byte intact.
3. **Compress.** Run the `caveman` skill's compression on the re-drafted sections only,
   preserving existing density, structure, and code blocks.
4. **Advance frontmatter.** Set `last_synced_commit` to the current `git rev-parse HEAD`.
5. **Approval gate.** Show the user a diff of the patched sections against the prior
   `AIBOARDING.md`. Content changes ALWAYS require approval before writing. Only the no-op
   pointer advance is automatic.

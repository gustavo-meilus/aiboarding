# create-aiboarding Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Author the `create-aiboarding` skill that generates a compressed `AIBOARDING.md` via a hybrid background-crawl + grilling flow and bootstraps the sync/update hooks into the repo.

**Architecture:** A prose `SKILL.md` (process instructions, not code) following the superpowers skill conventions. The skill runs six phases; Phase 6 installs the hook templates from Plan 1 by **agent-driven file operations** — the agent copies `templates/hooks/*` into the target repo's `.aiboarding/hooks/` and idempotently merges `templates/settings/hooks.json` into `.claude/settings.json` using its own Read/Edit/Write tools (a cross-platform JSON merge without `jq`/`node` is brittle, and install is a once-per-repo operation).

**Tech Stack:** Claude Code skill (`SKILL.md` + YAML frontmatter), markdown. Depends on Plan 1 artifacts (`templates/hooks/`, `templates/settings/hooks.json`) and the local `caveman` skill for Phase 5.

**Spec:** `docs/superpowers/specs/2026-05-28-create-onboarding-design.md`

> **Note on TDD:** This plan authors a prose skill, so the red-green-refactor loop does not apply. Each task instead: write the section → verify against the writing-skills checklist → commit. Use the `superpowers:writing-skills` skill while authoring to keep frontmatter and structure conformant.

---

## File Structure

- `skills/create-aiboarding/SKILL.md` — the skill: frontmatter + the six-phase process.

A single self-contained file. The hook artifacts it installs already live under `templates/` from Plan 1; this skill references them by relative path from the plugin root.

---

## Task 1: Skill scaffold + frontmatter + overview

**Files:**
- Create: `skills/create-aiboarding/SKILL.md`

- [ ] **Step 1: Write frontmatter + overview**

Create `skills/create-aiboarding/SKILL.md`:

```markdown
---
name: create-aiboarding
description: Use when a repo has no AIBOARDING.md and an agent needs onboarding context, or the user asks to generate one. Runs a hybrid background-crawl + relentless grilling interrogation to produce a compressed AIBOARDING.md, then installs the sync/update hooks. Also the fallback target when sync-aiboarding finds no doc.
---

# Creating AIBOARDING.md

Treat the AI as a fresh engineer. Generate a compressed, high-signal `AIBOARDING.md`
at the repo root, then bootstrap the hooks that keep it loaded and current.

**Announce at start:** "Using create-aiboarding to generate this repo's onboarding doc."

## Shared contracts
The document schema, hook layout, and drift tracking are fixed by the architecture
umbrella. Write the frontmatter exactly as: `aiboarding_version`, `generated` (today's
date), `last_synced_commit` (current `git rev-parse HEAD`). Body sections, in order:
1. Engineering Basics  2. Domain & Business Logic  3. AI-Specific Context.
```

- [ ] **Step 2: Verify triggering**

Use `superpowers:writing-skills` to check the `description` is in "Use when…" form and names concrete triggers (no AIBOARDING.md, explicit ask, sync fallback). Confirm `name` matches the directory.

- [ ] **Step 3: Commit**

```bash
git add skills/create-aiboarding/SKILL.md
git commit -m "feat: scaffold create-aiboarding skill frontmatter and contracts"
```

---

## Task 2: Phases 1–3 (Crawl, Grill, Reconcile)

**Files:**
- Modify: `skills/create-aiboarding/SKILL.md`

- [ ] **Step 1: Append the discovery + grilling + reconciliation phases**

Append to `skills/create-aiboarding/SKILL.md`:

```markdown
## Phase 1: Background crawl + initial grilling
Run two tracks in parallel.

**Track A — automated discovery (no user input):** read dependency manifests
(`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, etc.), the directory
structure, and any README/docs. Extract tech stack, build/test/run commands, and
standard engineering basics. Hold these findings for Phase 3.

**Track B — grilling interrogation:** open with:
> "I'm scanning your codebase structure in the background for the tech stack. While I
> do that: what is the core business problem this project solves?"
Then walk the conceptual tree **one question at a time**, challenging vague answers and
incentivizing a targeted brain-dump per micro-topic. Do not batch questions.

## Phase 2: Architectural & AI context
Steer the grilling toward architecture and AI-specific guardrails. Extract constraints
and known AI failure modes, e.g.:
> "You mentioned a custom Auth provider. What are the architectural gotchas or AI
> failure modes around it that a future sub-agent must not trip over?"
Capture failure modes explicitly so future agents avoid them.

## Phase 3: Reconciliation & gap analysis
**HARD GATE — do not start until BOTH Track A (crawl) and Track B (grilling) are
complete.** Cross-examine Track A findings against Track B answers. Run a short, final
grilling pass focused only on discrepancies, e.g.:
> "The crawl found a Postgres connection string, but you didn't mention a database. How
> does Postgres fit the core domain, and are there AI constraints here?"
```

- [ ] **Step 2: Verify**

Re-read the three phases against the spec's Phases 1–3. Confirm the hard gate before Phase 3, the one-question-at-a-time rule, and the two named example prompts are present.

- [ ] **Step 3: Commit**

```bash
git add skills/create-aiboarding/SKILL.md
git commit -m "feat: add create-aiboarding phases 1-3 (crawl, grill, reconcile)"
```

---

## Task 3: Phases 4–5 (Synthesis + Caveman compression)

**Files:**
- Modify: `skills/create-aiboarding/SKILL.md`

- [ ] **Step 1: Append synthesis + compression phases**

Append to `skills/create-aiboarding/SKILL.md`:

```markdown
## Phase 4: Synthesis & generation
Triggers when reconciliation reaches a natural conclusion. Combine verified Track A
findings with reconciled Track B domain knowledge. Draft `AIBOARDING.md` with the
umbrella frontmatter (set `last_synced_commit` to the current `git rev-parse HEAD`)
followed by the three body sections.

## Phase 5: Token compression
Before finalizing, pass the draft through the `caveman` skill's compression: strip
filler, pleasantries, articles, and hedging; convert verbose prose to terse,
fragment-heavy shorthand (`X -> Y`) while preserving 100% of technical accuracy,
structure, code blocks, and the frontmatter. Present the compressed, high-density
document to the user for approval before writing it to the repo root.
```

- [ ] **Step 2: Verify**

Confirm Phase 5 references the `caveman` skill and preserves frontmatter + code blocks; confirm Phase 4 writes `last_synced_commit` from `HEAD`, matching Plan 1's `read_frontmatter`/`post-commit` expectations.

- [ ] **Step 3: Commit**

```bash
git add skills/create-aiboarding/SKILL.md
git commit -m "feat: add create-aiboarding phases 4-5 (synthesis, caveman compression)"
```

---

## Task 4: Phase 6 (Hook installation / bootstrap)

**Files:**
- Modify: `skills/create-aiboarding/SKILL.md`

- [ ] **Step 1: Append the install phase with exact agent operations**

Append to `skills/create-aiboarding/SKILL.md`:

```markdown
## Phase 6: Hook installation & bootstrap
After the document is approved and written, install the hooks so enforcement is live.
This is done with your own file tools (no shell installer), for cross-platform safety.

1. **Copy hook scripts.** Create `<repo>/.aiboarding/hooks/` and copy these four files
   from the plugin's `templates/hooks/` verbatim: `run-hook.cmd`, `session-start`,
   `pre-task`, `post-commit`, and the shared `_lib`.
2. **Merge settings.** Read the plugin's `templates/settings/hooks.json`. Merge its
   `hooks` block into `<repo>/.claude/settings.json`:
   - If `.claude/settings.json` does not exist, create it containing exactly that block.
   - If it exists, merge per top-level event (`SessionStart`, `PreToolUse`, `PostToolUse`).
   - **Idempotency:** before adding an entry, check whether an `aiboarding` entry for that
     event already exists (a `command` containing `.aiboarding/hooks/run-hook.cmd`). If so,
     replace it in place; never duplicate.
3. **Report.** Tell the user which files were created and which hook entries were
   installed or updated. From now, sync-aiboarding injects the doc and update-aiboarding
   watches for drift.
```

- [ ] **Step 2: Verify**

Confirm the five copied files match Plan 1's `templates/hooks/` set, the merge targets the three events from `templates/settings/hooks.json`, and the idempotency rule matches on the `run-hook.cmd` command substring.

- [ ] **Step 3: Commit**

```bash
git add skills/create-aiboarding/SKILL.md
git commit -m "feat: add create-aiboarding phase 6 (agent-driven idempotent hook install)"
```

---

## Task 5: End-to-end verification

**Files:** none (manual verification)

- [ ] **Step 1: Dry-run on a scratch repo**

In a throwaway git repo with no `AIBOARDING.md`, invoke the skill. Confirm:
- Track A surfaces the real stack; Track B grills one question at a time.
- Phase 3 does not start until both tracks finish.
- The drafted doc has correct frontmatter (`last_synced_commit` == `HEAD`) and three sections.
- Phase 5 compression preserves structure and code blocks.

- [ ] **Step 2: Verify install side-effects**

After approval, confirm `.aiboarding/hooks/` holds the five files and `.claude/settings.json`
contains the three hook entries. Start a fresh session and confirm `session-start` injects
the new doc (`<aiboarding-context>` present). Re-run the skill and confirm install is
idempotent (no duplicate entries).

- [ ] **Step 3: Commit any fixes**

```bash
git add -A
git commit -m "fix: address create-aiboarding end-to-end verification findings"
```

---

## Self-Review

**Spec coverage:** Trigger/fallback → frontmatter description (Task 1). Phase 1 two-track crawl+grill → Task 2. Phase 2 AI context → Task 2. Phase 3 hard gate + reconciliation → Task 2. Phase 4 synthesis + frontmatter → Task 3. Phase 5 caveman → Task 3. Phase 6 hook install + idempotency → Task 4. End-to-end → Task 5. ✓

**Placeholder scan:** No TBD/TODO; each phase has concrete instructions and the two named example prompts from the spec are included verbatim.

**Consistency:** `last_synced_commit` written from `git rev-parse HEAD` (Tasks 1, 3) matches the value Plan 1's `post-commit`/`read_frontmatter` compares against. The five files copied in Phase 6 (Task 4) match Plan 1's `templates/hooks/` set exactly (`run-hook.cmd`, `session-start`, `pre-task`, `post-commit`, `_lib`). The merged events match `templates/settings/hooks.json`.

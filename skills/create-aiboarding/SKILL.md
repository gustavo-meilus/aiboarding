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

## Phase 6: Hook installation & bootstrap
After the document is approved and written, install the hooks so enforcement is live.
This is done with your own file tools (no shell installer), for cross-platform safety.

1. **Copy hook scripts.** Create `<repo>/.aiboarding/hooks/` and copy these five files
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

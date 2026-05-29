---
name: create-aiboarding
description: Use when a repo has no AIBOARDING.md and an agent needs onboarding context, or the user asks to generate one. Also the fallback target when sync-aiboarding finds no doc.
---

# Creating AIBOARDING.md

Treat the AI as a fresh engineer. Generate a compressed, high-signal `AIBOARDING.md`
at the repo root, then bootstrap the hooks that keep it loaded and current.

**Announce at start:** "Using create-aiboarding to generate this repo's onboarding doc."

## Shared contracts
The document schema, hook layout, and drift tracking are fixed by the architecture
umbrella. Write the frontmatter exactly as these three keys:
- `aiboarding_version: 1`
- `generated:` today's date in `YYYY-MM-DD` — use the session date if available, else `date +%F`.
- `last_synced_commit:` the current `git rev-parse HEAD`.

Body sections use H1 headings, in this exact order:
`# 1. Engineering Basics`, `# 2. Domain & Business Logic`, `# 3. AI-Specific Context`.

## Phase 1: Background crawl + initial grilling
Run two tracks. A single agent cannot truly act in parallel: perform Track A's file
reads first and hold the findings, then immediately open Track B and keep grilling.

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
Capture failure modes explicitly so future agents avoid them. Continue until you have
captured at least one architectural constraint and one AI-specific failure mode or
guardrail, then proceed.

## Phase 3: Reconciliation & gap analysis
**HARD GATE — do not start until BOTH Track A (crawl) and Track B (grilling) are
complete.** Cross-examine Track A findings against Track B answers. Run a short, final
grilling pass focused only on discrepancies, e.g.:
> "The crawl found a Postgres connection string, but you didn't mention a database. How
> does Postgres fit the core domain, and are there AI constraints here?"

## Phase 4: Synthesis & generation
When the reconciliation pass is complete and no open discrepancies remain, combine
verified Track A findings with reconciled Track B domain knowledge. Draft `AIBOARDING.md`
with the umbrella frontmatter (set `last_synced_commit` to the current `git rev-parse
HEAD`) followed by the three H1 body sections.

## Phase 5: Token compression
Before finalizing, pass the draft through the `caveman` skill's compression: strip
filler, pleasantries, articles, and hedging; convert verbose prose to terse,
fragment-heavy shorthand (`X -> Y`) while preserving 100% of technical accuracy,
structure, code blocks, and the frontmatter. Present the compressed, high-density
document to the user for approval before writing it to the repo root.

## Phase 6: Hook installation & bootstrap
After the document is approved and written, install the hooks so enforcement is live.
This is done with your own file tools (no shell installer), for cross-platform safety.

1. **Locate the templates.** They live in this plugin at `<plugin-root>/templates/`,
   where `<plugin-root>` is two levels up from this skill (`skills/create-aiboarding/`).
   Use `${CLAUDE_PLUGIN_ROOT}/templates` if that variable is set; otherwise resolve it
   relative to this skill's own directory.
2. **Copy hook scripts.** Create `<repo>/.aiboarding/hooks/` and copy these five files
   from `<plugin-root>/templates/hooks/` verbatim: `run-hook.cmd`, `session-start`,
   `pre-task`, `post-commit`, and the shared `_lib`.
3. **Merge settings.** Read `<plugin-root>/templates/settings/hooks.json`. Merge its
   `hooks` block into `<repo>/.claude/settings.json`:
   - If `.claude/settings.json` does not exist, create it containing exactly that block.
   - If it exists, merge per top-level event (`SessionStart`, `PreToolUse`, `PostToolUse`).
   - **Idempotency:** before adding an entry, check whether an `aiboarding` entry for that
     event already exists (a `command` containing `.aiboarding/hooks/run-hook.cmd`). If so,
     replace it in place; never duplicate.
4. **Verify and report.** Confirm the five hook files exist in `<repo>/.aiboarding/hooks/`
   and the three hook entries appear in `<repo>/.claude/settings.json`, then tell the user
   which files were created and which hook entries were installed or updated.

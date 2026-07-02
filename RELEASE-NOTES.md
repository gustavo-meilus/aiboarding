# aiboarding — Release Notes

> Canonical record of versioned changes, feature additions, and removals for the aiboarding project. This document tracks the build-out from the foundation release toward the full create → sync → update lifecycle.

<overview>
aiboarding onboards AI coding agents like fresh engineers: it maintains one compressed `AIBOARDING.md` per repository and uses committed hooks to inject it into every agent context and flag it when it drifts. The v0.1.0 foundation established the plugin scaffold, the cross-platform polyglot hook templates (the `sync` and `update` enforcement layer), and a dependency-free bash test harness. v0.1.1 added the `create-aiboarding` generation skill. v0.1.2 added the `update-aiboarding` triage skill — completing the create → sync → update lifecycle. v0.1.3 ships distribution (the marketplace listing) and a committed verification runbook for the live-runtime behaviors the test harness cannot reach. v0.2.0 fixes the `update-aiboarding` self-referential drift loop — the first production-hook behavior bug since distribution.
</overview>

## v0.3.0 — Canonical-File Pivot: AGENTS.md + CLAUDE.md (2026-07-02)

### Highlights

aiboarding pivots from injecting a custom `AIBOARDING.md` to managing the standard onboarding files: a cross-agent `AGENTS.md` (read natively by Codex, Copilot, Cursor, and others) plus a thin `CLAUDE.md` wrapper (`@AGENTS.md`) that Claude Code loads natively — including after `/compact`. Operational state moves to a `.aiboarding/state.json` sidecar, which fixes issue #1's root cause structurally: advancing the sync pointer never modifies an instruction file, so the drift hook can no longer be re-fired by its own bookkeeping. The six-phase generation engine, targeted-delta updates, and drift-on-uncertainty stance all carry over; a one-shot `migrate-aiboarding` skill moves existing repos across without losing their onboarding investment.

<release_entry version="0.3.0" status="EARLY">

### Fixed

- **Issue #1's root cause** — the sync pointer moved out of the committed instruction file into `.aiboarding/state.json`. The v0.2.0 doc-only-range suppression is retained only in the drift hook's legacy branch for unmigrated repos.

### Added

- **`create-agent-onboarding`** (alias: `create-aiboarding`) — six-phase engine retargeted to a nine-section tool-agnostic `AGENTS.md` + `CLAUDE.md` wrapper, with pre-flight routing (never overwrites existing onboarding files) and a blocking validation gate.
- **`update-agent-onboarding`** (alias: `update-aiboarding`) — no-op branch advances the state pointer only; targeted-delta patch unchanged.
- **`migrate-aiboarding`** — one-shot v1→v2 migration behind a single preview-first approval gate.
- **`drift-check` hook** (replaces `post-commit`) — state-sidecar pointer vs `HEAD`, config-driven ignored-path classification, stdin git-gate, legacy-layout branch.
- **Deterministic tools** — `inject-fenced` (idempotent marker-fenced blocks) and `check-size-budget` (Codex 32 KiB cap enforcement); `_lib` gains pure-bash JSON state readers.

### Changed

- Old skill names remain as deprecated alias stubs. Plugin manifest `0.2.0` → `0.3.0`.

### Known limitations

- One state-only pointer-advance commit per cycle still lands (committed state = team-shared pointer); the hook classifies it as non-drift. New skill reasoning branches not yet exercised against a live runtime.

</release_entry>

## v0.2.0 — Drift-Hook Loop Fix (2026-06-09)

### Highlights

The `post-commit` drift hook no longer loops on itself. Because `last_synced_commit` lives inside the committed `AIBOARDING.md`, the commit that advanced the pointer always pushed `HEAD` past it and re-fired the nudge — an unbounded chain of no-op commits and prompts. The hook now suppresses the nudge when every commit in `last_synced_commit..HEAD` touches only `AIBOARDING.md`, while any real (non-doc) change, empty diff, or git failure still nudges. First production-hook behavior fix since distribution; no skill or marketplace change.

<release_entry version="0.2.0" status="EARLY">

### Fixed

- **Self-referential drift loop** ([#1](https://github.com/gustavo-meilus/aiboarding/issues/1)) — `templates/hooks/post-commit` inspects the changed-file set of `last_synced_commit..HEAD`; if every path is `AIBOARDING.md` (the no-op pointer-advance and content-patch commits), the nudge is suppressed. Non-doc paths, an empty diff, or a git failure (e.g. a rebased-away pointer) fall through to a nudge. Chosen over commit-message matching: one rule covers both the pointer-advance and the content-patch self-trigger, with no message-format dependency.

### Changed

- Plugin manifest `0.1.3` → `0.2.0`.

### Known limitations

- One no-op pointer-advance marker commit per real-change cycle still lands — now silently absorbed rather than re-nudging. Sync state stays in the tracked doc (no sidecar). Prior caveats (1a hook injection, 1e skill reasoning, `PostToolUse` matcher breadth) remain.

</release_entry>

## v0.1.3 — Distribution & Verification Runbook (2026-05-29)

### Highlights

The plugin becomes installable, and the behaviors that unit tests structurally cannot reach get a committed home. A single-plugin marketplace manifest makes `/plugin install aiboarding@aiboarding` resolve, and `docs/VERIFICATION.md` captures the manual protocols — the marketplace install check, the `PreToolUse[Task]` injection canary test (with a design-only fallback decision tree), and the four `update-aiboarding` reasoning-branch cases — so the remaining live-runtime verification is precise and repeatable rather than re-derived each time. No production hook or skill code changed.

<release_entry version="0.1.3" status="EARLY">

### Added

- **Marketplace manifest** (`.claude-plugin/marketplace.json`) — single-plugin marketplace (name `aiboarding`, `source: "./"`); the published install commands now resolve.
- **Verification runbook** (`docs/VERIFICATION.md`) — manual protocols with setup/steps/expected/pass-fail for: **2a** marketplace install; **1a** `PreToolUse[Task]` injection canary protocol + a design-only `additionalContext` → `updatedInput` decision tree; **1e** the four `update-aiboarding` reasoning-branch cases.

### Changed

- Plugin manifest `0.1.2` → `0.1.3`; README roadmap links the runbook and reflects the published marketplace listing.

### Known limitations

- The runbook protocols are manual and not yet run against a live runtime; 1a (hook injection) and 1e (skill reasoning) stay unverified. The `updatedInput` fallback is design-only — no code unless the 1a protocol fails. Prior caveats (Phase 6 path resolution, `PostToolUse` matcher breadth) remain.

</release_entry>

## v0.1.2 — update-aiboarding Skill (2026-05-29)

### Highlights

The update half of the lifecycle lands, closing the loop. `update-aiboarding` is the reasoning skill that the `post-commit` drift hook nudges toward: it triages whether commits since the last sync touch the document's scope, then either silently advances the drift pointer or runs a targeted-delta patch that re-drafts only the affected sections. With it, a repo's `AIBOARDING.md` stays current as the code evolves without re-grilling the whole project.

<release_entry version="0.1.2" status="EARLY">

### Added

- **`update-aiboarding` skill** — a prose triage skill:
  1. **Triage** — read `last_synced_commit`, run `git diff <last_synced_commit>..HEAD`, reflect on the conversation, classify scope impact across the three H1 sections. A missing/empty pointer routes to full re-validation rather than a silent no-op.
  2. **No-op branch** — nothing relevant changed: advance the pointer to `HEAD` automatically (no approval, no body rewrite), stopping the drift hook from re-nudging.
  3. **Targeted-delta patch** — scope drifted: reuse `create-aiboarding`'s Phases 1–3 scoped grill and the `caveman` compression on the re-drafted sections only, leaving untouched sections byte-for-byte intact, advancing the pointer, and gating every content change on user approval.

### Changed

- Plugin manifest `0.1.1` → `0.1.2`; README and docs updated to mark `update-aiboarding` shipped and the lifecycle complete.

### Known limitations

- The grill/synthesis/approval branches are agent-reasoning behaviors not yet exercised against a live runtime; the deterministic git-diff assumptions the skill relies on *are* verified. Prior hook-injection and Phase 6 path-resolution caveats remain.

</release_entry>

## v0.1.1 — create-aiboarding Skill (2026-05-29)

### Highlights

The generation half of the lifecycle lands. `create-aiboarding` is a six-phase prose skill that interviews the user and crawls the codebase to author `AIBOARDING.md`, compresses it via the `caveman` skill, and installs the v0.1.0 hook templates into the target repo. After running it, a repo has both a document and a live `sync` enforcement layer.

<release_entry version="0.1.1" status="EARLY">

### Added

- **`create-aiboarding` skill** — six phases:
  1. **Crawl + grill** — Track A reads manifests/structure/docs; Track B grills the user one question at a time. (A single agent serializes: crawl first, hold findings, then grill.)
  2. **Architecture & AI context** — extracts constraints and AI failure modes.
  3. **Reconciliation** — hard-gated on both tracks finishing; grills discrepancies.
  4. **Synthesis** — drafts the umbrella schema (frontmatter + three H1 sections).
  5. **Compression** — `caveman` pass, user-approved before write.
  6. **Install** — agent-driven, idempotent copy of the five hook templates into `<repo>/.aiboarding/hooks/` plus a merge of the settings snippet into `<repo>/.claude/settings.json`.

### Changed

- Plugin manifest `0.1.0` → `0.1.1`; README and docs updated to mark `create-aiboarding` shipped.

### Known limitations

- `update-aiboarding` (drift triage) is still planned — the `post-commit` hook nudges for it but the skill does not yet exist.
- Hook-injection runtime behaviors (PreToolUse `additionalContext`, the `Bash` matcher breadth) and Phase 6's plugin-root path resolution remain unverified against a live install.

</release_entry>

## v0.1.0 — Foundation: Plugin Scaffold & Hook Templates (2026-05-29)

### Highlights

First public release. It ships the deterministic enforcement layer — the hooks that load `AIBOARDING.md` into agents and detect drift — without yet shipping the skills that author the document. This sequencing is deliberate: the hooks are pure, unit-testable scripts that everything else installs, so they are built and proven first.

<release_entry version="0.1.0" status="FOUNDATION">

### What ships

- **Plugin scaffold** — `.claude-plugin/plugin.json` (`aiboarding` namespace).
- **Sync hooks** — `session-start` (SessionStart injection + missing-doc fallback) and `pre-task` (PreToolUse[Task] sub-agent injection).
- **Update hook** — `post-commit` (PostToolUse drift nudge comparing `last_synced_commit` to `HEAD`).
- **Polyglot wrapper** — `run-hook.cmd`, one file valid as both CMD and bash, with graceful Windows degradation when Git Bash is absent.
- **Shared library** — `_lib`: pure-bash JSON escaping, path resolution, frontmatter reading, and Claude Code hook-output emission.
- **Settings snippet** — `templates/settings/hooks.json` wiring all three hooks.
- **Test harness** — five dependency-free bash suites; all passing.
- **Design docs** — architecture umbrella + create/sync/update specs + three implementation plans under `docs/superpowers/`.

### The document contract

`AIBOARDING.md` carries drift state in frontmatter (`aiboarding_version`, `generated`, `last_synced_commit`) over three caveman-compressed sections: Engineering Basics, Domain & Business Logic, AI-Specific Context. `last_synced_commit` is the single drift signal consumed by `post-commit` and the planned `update-aiboarding`.

### Cross-platform model

Hooks run through a polyglot `run-hook.cmd`: on Windows, CMD locates Git Bash and dispatches; on POSIX, bash skips the CMD heredoc and runs the named script. Extensionless script names avoid Claude Code's Windows `.sh` auto-detection, and `.gitattributes` pins LF endings so shebangs and string comparisons survive Windows checkouts.

### Known limitations

- No user-facing skills/commands yet — `create-aiboarding`, `update-aiboarding`, and the hook installer are designed but unimplemented (v0.2.0–v0.3.0).
- `PreToolUse` sub-agent injection (`additionalContext`) is unverified against the live runtime; may switch to `updatedInput`.
- `PostToolUse` matcher is `Bash` (self-gated); narrowing to `git commit` deferred.
- Windows requires Git for Windows; absent it, injection no-ops silently.

</release_entry>

### Roadmap

- **Lifecycle complete** — create → sync → update all shipped as of v0.1.2.
- **Distribution shipped (v0.1.3)** — the marketplace manifest is published; `/plugin install aiboarding@aiboarding` resolves.
- **Drift-loop fixed (v0.2.0)** — the `post-commit` self-referential nudge loop is closed via range-filtering.
- **Hardening** — run the committed [verification runbook](./docs/VERIFICATION.md) against a live runtime to confirm hook injection (1a) and `update-aiboarding` reasoning (1e); narrow the `PostToolUse` matcher to `git commit`.

### Full changelog

See `CHANGELOG.md`.

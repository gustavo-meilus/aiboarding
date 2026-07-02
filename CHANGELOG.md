# Changelog

## Distribution

aiboarding is a Claude Code plugin distributed from `gustavo-meilus/aiboarding`. Each entry below corresponds to a git tag of the same name on `main`.

**Install (Claude Code) — marketplace listing published as of v0.1.3:**

```text
/plugin marketplace add gustavo-meilus/aiboarding
/plugin install aiboarding@aiboarding
```

**Pin to a specific version:**

```text
/plugin install aiboarding@aiboarding --version v0.1.0
```

## 0.3.0 — Canonical-File Pivot: AGENTS.md + CLAUDE.md (2026-07-02)

The strategic pivot: aiboarding stops generating a custom `AIBOARDING.md` and becomes a lifecycle manager for the standard onboarding files — a cross-agent `AGENTS.md` (read natively by Codex, Copilot, Cursor) plus a thin `CLAUDE.md` wrapper (`@AGENTS.md`) that Claude Code loads natively. Operational state moves out of the instruction files into a `.aiboarding/state.json` sidecar.

### Fixed

- **Issue [#1](https://github.com/gustavo-meilus/aiboarding/issues/1)'s root cause, structurally** — the sync pointer no longer lives inside a committed instruction file. Advancing `last_synced_commit` writes only `.aiboarding/state.json`, so the pointer-advance can never re-fire the drift hook against the doc itself. The v0.2.0 doc-only-range suppression survives solely in the legacy branch for unmigrated repos.

### Added

- **`create-agent-onboarding` skill** — the v0.1.1 six-phase engine (crawl + grilling + hard-gated reconciliation + compression + idempotent install), retargeted: synthesis lands in a nine-section tool-agnostic `AGENTS.md` (Project Purpose → Escalation), delivery is native loading via the `CLAUDE.md` wrapper, and a new **blocking validation gate** checks the import line, size budget, command resolution, and pointer freshness before success may be reported. Pre-flight routing protects existing files: legacy `AIBOARDING.md` → migration; existing `AGENTS.md`/`CLAUDE.md` → never overwritten.
- **`update-agent-onboarding` skill** — triage now reads the state sidecar; the no-op branch advances the pointer **without touching any instruction file** (the hard invariant this release exists for). Targeted-delta discipline unchanged: patch only affected sections, byte-preserve the rest, approval-gate every content change.
- **`migrate-aiboarding` skill** — one-shot v1→v2: frontmatter → `state.json`, three H1 sections mapped onto the nine-section schema (scoped grill only for the two unmapped sections), hook rewiring, archive-or-banner retirement of the legacy doc, all behind a single preview-first approval gate.
- **`drift-check` hook** (replaces `post-commit`) — compares `state.json:last_synced_commit` to `HEAD`; range classification is config-driven (always-ignored `AGENTS.md`/`CLAUDE.md`/`.aiboarding/*` plus `config.json:ignored_paths` globs); stdin git-gate as defense in depth; legacy `AIBOARDING.md` branch preserves exact v0.2.0 behavior with a migration nudge.
- **Deterministic tools** (`templates/tools/`, installed to `<repo>/.aiboarding/tools/`) — `inject-fenced` (idempotent `<!-- aiboarding-begin/end -->` block injection with clean removal) and `check-size-budget` (220-line/24 KiB warnings; hard fail past the 32 KiB Codex `project_doc_max_bytes` silent-truncation cap).
- **State/config templates** — default `.aiboarding/config.json` (compression level, size budgets, drift `ignored_paths`) and the `.aiboarding/.gitignore` payload.
- **`_lib` state readers** — `resolve_paths`, `json_get`, `json_get_array_items`, `path_matches_any`: pure-bash line scanners honoring the one-key-per-line write contract (still no `jq`/`sed`/`awk`).

### Changed

- `skills/create-aiboarding` and `skills/update-aiboarding` are now thin **deprecated alias stubs** that defer to the new skills.
- Plugin manifest version `0.2.0` → `0.3.0`.

### Known Limitations

- One state-only pointer-advance commit per cycle still lands (state is committed for a team-shared pointer); the drift hook classifies it as non-drift via the always-ignored path set.
- The new skills' reasoning branches (routing, migration mapping, validation gate) are agent-reasoning behaviors verified by review, not yet against a live runtime — consistent with prior releases.

---

## 0.2.0 — Drift-Hook Loop Fix (2026-06-09)

Fixes the first production-hook behavior bug since distribution: the `update-aiboarding` no-op pointer-advance created a self-referential drift loop. No skill or distribution change.

### Fixed

- **Self-referential drift loop** ([#1](https://github.com/gustavo-meilus/aiboarding/issues/1)) — because `last_synced_commit` lives inside the committed `AIBOARDING.md`, every commit that advanced the pointer pushed `HEAD` past it and re-fired the `post-commit` drift hook, generating an unbounded chain of no-op commits and nudges. The hook now inspects the range: when every commit in `last_synced_commit..HEAD` touches only `AIBOARDING.md`, the nudge is suppressed. Any non-doc path, empty diff, or git failure (e.g. a rebased-away pointer) still nudges — preserving the drift-on-uncertainty stance. Chosen over commit-message matching because it catches both the no-op pointer-advance and the content-patch commit in one rule, with no message-format dependency.

### Changed

- Plugin manifest version `0.1.3` → `0.2.0`.

### Known Limitations

- One no-op pointer-advance marker commit per real-change cycle still lands; it is now silently absorbed instead of re-nudging. Sync state remains in the tracked doc (no sidecar). Prior live-runtime caveats (1a hook injection, 1e skill reasoning, `PostToolUse` matcher breadth) remain.

---

## 0.1.3 — Distribution & Verification Runbook (2026-05-29)

Makes the plugin installable and documents how to verify the behaviors the test harness cannot reach. No production hook or skill code changed.

### Added

- **Marketplace manifest** (`.claude-plugin/marketplace.json`) — a single-plugin marketplace (name `aiboarding`, `source: "./"`) so the published install commands resolve: `/plugin marketplace add gustavo-meilus/aiboarding` then `/plugin install aiboarding@aiboarding`.
- **Verification runbook** (`docs/VERIFICATION.md`) — committed manual protocols, each with setup/steps/expected/pass-fail:
  - **2a** — marketplace install check.
  - **1a** — `PreToolUse[Task]` injection canary protocol, plus a design-only `additionalContext` → `updatedInput` decision tree for the contingent fix if injection fails.
  - **1e** — the four `update-aiboarding` reasoning-branch cases (no-op, targeted-delta, hook-loop sanity, empty-pointer guard).

### Changed

- Plugin manifest version `0.1.2` → `0.1.3`.
- README roadmap links the verification runbook; status reflects the published marketplace listing.

### Known Limitations

- The runbook protocols are **manual and not yet run** against a live Claude Code install; the hook-injection (1a) and `update-aiboarding` skill-reasoning (1e) behaviors remain unverified. The `updatedInput` fallback (Mechanism B) is **design-only** — no code unless the 1a protocol fails.

---

## 0.1.2 — update-aiboarding Skill (2026-05-29)

Completes the create → sync → update lifecycle: the `update-aiboarding` skill — the reasoning half that the `post-commit` drift hook nudges toward — now exists.

### Added

- **`update-aiboarding` skill** (`skills/update-aiboarding/SKILL.md`) — a prose triage skill:
  - **Triage** — reads `last_synced_commit` from the `AIBOARDING.md` frontmatter, runs `git diff <last_synced_commit>..HEAD`, reflects on the conversation, and classifies scope impact across the three H1 sections. A missing/empty pointer is guarded: it routes to a full re-validation rather than silently no-op'ing (an empty `git diff ..HEAD` resolves to `HEAD..HEAD` and shows no delta).
  - **No-op branch** — when nothing in scope changed, advances `last_synced_commit` to `HEAD` automatically (no approval, no body rewrite) so the drift hook stops re-nudging.
  - **Targeted-delta patch** — when scope drifted, reuses `create-aiboarding`'s Phases 1–3 (scoped grill) and the `caveman` compression pass, re-drafting only the affected sections (untouched sections left byte-for-byte intact), advancing the pointer, and gating every content change on user approval.

### Changed

- Plugin manifest version `0.1.1` → `0.1.2`.
- README: `update-aiboarding` moved from *planned* to *shipped*; status, lifecycle table, Quick Start, repository layout, and roadmap updated to reflect the now-complete lifecycle.

### Known Limitations

- **Skill-reasoning runtime caveats.** `update-aiboarding`'s grill/synthesis/approval branches are agent-reasoning behaviors that a shell cannot exercise; they are not yet verified against a live runtime (the deterministic git-diff assumptions the skill rests on *are* verified). The v0.1.0/v0.1.1 hook-injection and Phase 6 path-resolution caveats also remain.

---

## 0.1.1 — create-aiboarding Skill (2026-05-29)

Adds the generation half of the lifecycle: the `create-aiboarding` skill that authors `AIBOARDING.md` and installs the v0.1.0 hook templates into a target repo.

### Added

- **`create-aiboarding` skill** (`skills/create-aiboarding/SKILL.md`) — a six-phase prose skill:
  - **Phase 1** — parallel-style discovery: a background crawl of dependency manifests, structure, and docs (Track A) alongside a relentless, one-question-at-a-time grilling interrogation (Track B).
  - **Phase 2** — steers the interrogation toward architectural constraints and AI-specific failure modes, with an explicit completion criterion.
  - **Phase 3** — a **hard gate** (both tracks must finish first) followed by reconciliation grilling on discrepancies between the crawl and the user's answers.
  - **Phase 4** — synthesis into the umbrella document schema (frontmatter + three H1 sections), with `last_synced_commit` set to `HEAD`.
  - **Phase 5** — `caveman`-skill compression, preserving structure/code/frontmatter, gated on user approval before writing.
  - **Phase 6** — agent-driven, idempotent install: copies the five hook templates into `<repo>/.aiboarding/hooks/` and merges `templates/settings/hooks.json` into `<repo>/.claude/settings.json`.

### Changed

- Plugin manifest version `0.1.0` → `0.1.1`.
- README: `create-aiboarding` moved from *planned* to *shipped*; Quick Start, lifecycle table, repository layout, and roadmap updated.

### Known Limitations

- **`update-aiboarding` not yet implemented.** The `post-commit` hook nudges to run it, but the drift-triage skill itself is still planned. Running `create-aiboarding` produces a working create + sync flow; the automated update flow is not yet available.
- **Skill runtime caveats unchanged from v0.1.0** — PreToolUse `additionalContext` delivery to sub-agents is unverified; the `PostToolUse` matcher remains `Bash` (self-gated). Phase 6's `${CLAUDE_PLUGIN_ROOT}` / skill-relative template-path resolution is not yet exercised against a live install.

---

## 0.1.0 — Foundation: Plugin Scaffold & Hook Templates (2026-05-29)

First public release. Ships the plugin scaffold and the cross-platform `sync`/`update` hook templates with a full test harness. The generation and update skills are designed (see `docs/superpowers/`) but not yet implemented.

### Added

- **Plugin manifest** — `.claude-plugin/plugin.json` (`aiboarding` namespace, `v0.1.0`).
- **Shared hook library** — `templates/hooks/_lib`: pure-bash JSON escaping (no `jq`/`sed`/`awk`), project/document path resolution, frontmatter reader (scoped to the `---` block), and the Claude Code `hookSpecificOutput` emitter.
- **`session-start` hook** — `SessionStart` (`startup|clear|compact`) injection of `AIBOARDING.md` as agent context; missing-document fallback prompts the user to run `create-aiboarding`.
- **`pre-task` hook** — `PreToolUse[Task]` injection of the document into spawned sub-agents (workaround for the absence of a native sub-agent-spawn hook).
- **`post-commit` hook** — `PostToolUse[Bash]` drift nudge comparing the frontmatter `last_synced_commit` to git `HEAD`; silent when no document, no `HEAD`, or in-sync.
- **`run-hook.cmd`** — cross-platform polyglot wrapper (valid CMD and bash); locates Git Bash on Windows, runs directly on POSIX, and degrades silently when no bash is available.
- **Settings snippet** — `templates/settings/hooks.json`, the `.claude/settings.json` block wiring all three hooks via `run-hook.cmd`.
- **Test harness** — dependency-free bash harness (`tests/run.sh`, `tests/lib/assert.sh`) with five suites covering the shared library and every hook, plus `with-doc`/`no-doc` fixtures.
- **`.gitattributes`** — pins LF line endings for all extensionless hook scripts and the polyglot wrapper (CRLF breaks Git Bash shebangs and string comparisons on Windows).
- **Design artifacts** — architecture umbrella, `create`/`sync`/`update` specs, and three implementation plans under `docs/superpowers/`.

### Known Limitations

- **No user-facing skills or commands yet.** `create-aiboarding` (generation) and `update-aiboarding` (drift triage), plus the installer that copies the hook templates into a target repo's `.aiboarding/hooks/` and merges the settings snippet, are designed but unimplemented. Targeted for v0.2.0–v0.3.0.
- **PreToolUse injection unverified.** `pre-task` emits `hookSpecificOutput.additionalContext`; whether the live Claude Code runtime delivers this to the spawned `Task` sub-agent is unconfirmed. If not, the mechanism switches to `updatedInput`.
- **`PostToolUse` matcher breadth.** The matcher is `Bash` (every bash call); `post-commit` self-gates to silence, but command-content narrowing to `git commit` is deferred.
- **Windows requires Git for Windows.** Absent `bash.exe`, hook injection no-ops silently rather than erroring.

### Non-Goals (v0.1.0)

- Generating or updating the document (owned by the planned `create`/`update` skills).
- A marketplace listing — distribution wiring lands alongside the v0.2.0 skills.

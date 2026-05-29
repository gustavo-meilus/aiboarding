# Changelog

## Distribution

aiboarding is a Claude Code plugin distributed from `gustavo-meilus/aiboarding`. Each entry below corresponds to a git tag of the same name on `main`.

**Install (Claude Code) — marketplace registration pending:**

```text
/plugin marketplace add gustavo-meilus/aiboarding
/plugin install aiboarding@aiboarding
```

**Pin to a specific version:**

```text
/plugin install aiboarding@aiboarding --version v0.1.0
```

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

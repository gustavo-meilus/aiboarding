# Changelog

## Distribution

aiboarding is a Claude Code plugin distributed from `gustavo-meilus/aiboarding`. Each entry below corresponds to a git tag of the same name on `main`.

**Install (Claude Code) — planned for v0.2.0, once the skills ship:**

```text
/plugin marketplace add gustavo-meilus/aiboarding
/plugin install aiboarding@aiboarding
```

**Pin to a specific version:**

```text
/plugin install aiboarding@aiboarding --version v0.1.0
```

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

# Design Spec: `sync-aiboarding`

## Overview
`sync-aiboarding` guarantees that an agent reads the project's `AIBOARDING.md` on
entry. It is a **hook bundle, not a reasoning skill** — a `SessionStart` hook that
emits the document as context *is* the sync; no model reasoning is required. Its only
non-deterministic moment is the missing-document fallback, which emits a prompt to run
`create-aiboarding`.

> **Umbrella:** Shared contracts (document schema, hook layout, drift tracking) are
> defined in [`2026-05-29-aiboarding-architecture.md`](./2026-05-29-aiboarding-architecture.md).
> This spec implements the `SessionStart` and `PreToolUse[Task]` rows of that hook table.

## Mechanism: Polyglot Hooks
The pattern is adopted directly from `obra/superpowers` (the framework `aiboarding`
extends), which solved cross-platform hooks in production.

* **Committed per-project.** Scripts live under `.aiboarding/hooks/`, committed to the
  repo so they travel with the team. `.claude/settings.json` (also committed) references
  them via `${CLAUDE_PROJECT_DIR}`.
* **Polyglot wrapper.** A single `run-hook.cmd` is valid CMD *and* valid bash. On Windows,
  CMD runs the batch half, which locates Git Bash (`C:\Program Files\Git\bin\bash.exe`,
  then `where bash`) and invokes the named script. On macOS/Linux, bash treats the CMD
  block as a no-op heredoc and runs the script directly. `hooks` entries call
  `run-hook.cmd <script-name>`.
* **Extensionless script names** (`session-start`, `pre-task`) — deliberately without
  `.sh`, because Claude Code's Windows auto-detection prepends `bash` to any command
  containing `.sh` and breaks it.
* **Graceful degradation.** If no bash is found on Windows, the wrapper exits `0`
  silently. Injection no-ops rather than erroring; the project still works.
* **Bash hygiene.** Scripts avoid `sed`/`awk` and JSON-escape using pure bash parameter
  substitution (per superpowers' `escape_for_json`).

The hook scripts and `.claude/settings.json` entries are written into the repo by
`create-aiboarding` Phase 6 (bootstrap).

## Dependency
Windows contributors need **Git for Windows** installed (provides `bash.exe`). This is a
reasonable assumption in a git repo; absent it, injection silently no-ops.

## Hook 1: `SessionStart` — document injection
* **Matcher:** `startup|clear|compact`. Matches superpowers' proven matcher. `resume` is
  **omitted**: a resumed session already retains the earlier injection, so re-injecting is
  redundant. `compact` is the critical one — context is lost after compaction and must be
  rebuilt.
* **Script:** `session-start` reads `AIBOARDING.md` from the repo root, JSON-escapes the
  body, and emits it as context.
* **Output contract** (platform-aware, mirroring superpowers):
  * Claude Code: `{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "<doc>"}}`
  * Cursor: `{"additional_context": "<doc>"}`
  * Copilot CLI / SDK standard: `{"additionalContext": "<doc>"}`
* **Injected wrapper:** the document body is wrapped in a short directive header so the
  agent treats it as authoritative onboarding context, e.g.
  `<aiboarding-context>\n<doc body>\n</aiboarding-context>`.
* **Missing-document fallback:** if `AIBOARDING.md` is absent, emit context instructing the
  agent to offer to run `create-aiboarding`. This is the linkage for `create-aiboarding`'s
  implicit-fallback trigger.

## Hook 2: `PreToolUse[Task]` — sub-agent injection
* **Matcher:** `Task` (the sub-agent spawn tool). This is the workaround for the absence of
  a native sub-agent-spawn hook.
* **Script:** `pre-task` reads `AIBOARDING.md` and supplies it so the spawned sub-agent
  starts with the same onboarding context as the parent.
* **Implementation risk (must verify at build time):** the exact PreToolUse injection
  mechanism is Claude-Code-version-dependent. Depending on the installed version, the hook
  either returns `hookSpecificOutput.additionalContext` (context appended for the call) or
  supplies an `updatedInput` that prepends the doc to the `Task` prompt. The implementation
  plan must confirm which the target CC version supports before committing to one path.
* **If `AIBOARDING.md` is absent:** no-op (no fallback prompt here; the parent session's
  `SessionStart` already handled that).

## Out of Scope
* Generating or updating the document (owned by `create-aiboarding` / `update-aiboarding`).
* Deciding *when* the document is stale (owned by `update-aiboarding`).
* Installing the hooks (owned by `create-aiboarding` Phase 6); this spec defines *what* gets
  installed.

## Verification
* Manual: on a repo with `AIBOARDING.md`, start a fresh session and confirm the document
  appears in context; trigger a compaction and confirm re-injection; spawn a sub-agent and
  confirm it receives the doc.
* Negative: on a repo without `AIBOARDING.md`, confirm the fallback prompt appears and no
  error is raised.
* Windows-without-bash: confirm silent no-op (exit 0), no error surfaced to the user.

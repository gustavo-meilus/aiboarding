## Context

See `proposal.md` for motivation and `specs/codex-lifecycle-hooks/spec.md` for the host contract. Codex supports a Windows-only `commandWindows`, runs hook commands from the session working directory, supplies plugin hooks with `PLUGIN_ROOT`, and sends one JSON event on standard input ([OpenAI Hooks documentation](https://learn.chatgpt.com/docs/hooks)). The current manifest gives Windows a Bash command, while native Codex executes that override as a Windows command. The repository already ships a `run-hook.cmd` polyglot launcher and requires installed `.aiboarding/hooks/` copies to byte-match `templates/`.

## Goals / Non-Goals

**Goals:**

- Keep one Bash lifecycle implementation and one shared decision path.
- Use the host-native command syntax at the manifest boundary.
- Distinguish Git Bash from the Windows WSL compatibility shim.
- Decode only the native Windows path escaping needed before repository lookup.
- Prove the configured Windows command with `cmd.exe`, not a Bash simulation.

**Non-Goals:**

- Reimplement lifecycle classification in PowerShell or batch.
- Bridge a native Windows Codex process into a WSL filesystem/process environment.
- Make optional hooks a prerequisite for any AIBoarding skill.
- Change event matching, drift categories, or emitted lifecycle guidance.

## Decisions

### Keep host-specific launch syntax in the manifest

Retain the existing Bash command for Unix, macOS, and Codex sessions running inside WSL. Change each Windows override to call `templates/hooks/run-hook.cmd` with `%PLUGIN_ROOT%` syntax and pass the existing `hooks/codex-lifecycle` path as its script argument. Quoting must preserve plugin roots containing spaces.

Alternative: invoke bare `bash` on every host. Rejected because executable lookup on native Windows can select `C:\Windows\System32\bash.exe`, which expects WSL paths rather than the Windows plugin path.

### Reuse and narrow the existing launcher

Extend `run-hook.cmd` only as needed to dispatch a script outside its own directory, prefer Git for Windows Bash, and remove the generic PATH fallback that can select the WSL shim. If no compatible Git Bash is found, return success without output. Keep the template and self-hosted managed copy identical.

Alternative: add a Codex-only Windows launcher. Rejected because the existing wrapper already owns this portability boundary and a second launcher would duplicate detection and quoting behavior.

### Normalize `cwd` only at the Codex adapter boundary

After extracting `cwd` from the event JSON, collapse JSON-escaped backslash pairs before validating the absolute path and calling Git. Do not teach the runtime-neutral lifecycle tools about Codex JSON or Windows escaping.

Alternative: add a general JSON parser. Rejected because no parser runtime is guaranteed by the plugin and Windows paths cannot contain the quote character that would require broader string decoding here.

### Test the native interpreters and retain live evidence

Keep platform-neutral adapter fixtures. On Windows, execute the exact manifest override with `cmd.exe` and a payload whose `cwd` contains escaped backslashes; retain Bash execution for Unix/WSL coverage. Structural tests shall ensure every Windows event uses the wrapper, the wrapper cannot fall through to an arbitrary `bash` executable, and template/self-host copies remain synchronized. Extend the manual Codex protocol to record native Windows with Git Bash, native Windows without compatible Bash, and WSL/Unix outcomes separately.

Alternative: continue evaluating `commandWindows` via `bash -c`. Rejected because it changes both environment syntax and executable lookup, reproducing neither native Codex behavior nor the failure.

## Risks / Trade-offs

- [Git Bash installed outside discoverable Git locations] → Prefer paths derived from Git for Windows plus its standard install locations; otherwise preserve the silent manual fallback.
- [Minimal `cwd` decoding is not a full JSON parser] → Limit the transformation to the already extracted Windows path and cover spaces plus escaped backslashes; adopt a parser only if Codex sends path forms this boundary cannot represent.
- [No-Git-Bash Windows loses automatic nudges] → Hooks remain optional and silent, and documentation keeps explicit skill invocation as the supported fallback.
- [Host behavior changes in a future Codex release] → Keep native-interpreter fixtures and record Codex version and host in live verification evidence.

## Migration Plan

Ship the manifest, wrapper, adapter, tests, synchronized self-host copy, and host-matrix documentation together. Existing plugin installs will require hook trust review because the hook definition changes. Rollback restores the previous bundled files; skills and state remain compatible because no lifecycle decision or state schema changes.

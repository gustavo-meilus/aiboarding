## Why

Codex runs `commandWindows` through `cmd.exe`, but AIBoarding currently launches a bare `bash` command with a Windows plugin path. On native Windows this can select WSL's incompatible Bash and exit 127; even Git Bash receives JSON-escaped Windows paths that the adapter does not decode.

## What Changes

- Route native Windows Codex lifecycle events through the existing `run-hook.cmd` portability wrapper instead of invoking bare `bash`.
- Make the wrapper select a Windows-compatible Git Bash and silently preserve manual skill operation when none is available.
- Decode native Windows path escaping at the Codex adapter boundary while leaving shared lifecycle decisions unchanged.
- Verify native `cmd.exe`, Git Bash, WSL/Unix launch, Windows-path payloads, silent fallback, and template/package consistency.
- Document the supported host matrix: full hooks on Unix/macOS, WSL, and native Windows with Git Bash; manual lifecycle fallback on native Windows without a compatible Bash.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `codex-lifecycle-hooks`: Strengthen launcher portability, Windows payload translation, graceful fallback, and platform-specific verification requirements.

## Impact

Affected areas are the bundled Codex hook manifest and adapter, the shared hook launcher template, deterministic plugin/Codex/hook tests, and runtime verification documentation. The change adds no dependency and does not alter lifecycle classification semantics, generated onboarding content, or manual skill behavior.

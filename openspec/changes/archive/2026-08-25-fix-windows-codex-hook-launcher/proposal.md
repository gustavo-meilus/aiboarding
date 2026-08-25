## Why

Codex selects the Windows hook command but runs it through Bash, while AIBoarding's `commandWindows` values use PowerShell's `$env:PLUGIN_ROOT` syntax. Bash therefore resolves an invalid `:PLUGIN_ROOT/...` path, exits 127, and prevents all bundled lifecycle events—including onboarding-drift detection—from reaching the existing adapter on Windows.

## What Changes

- Make every Windows Codex lifecycle handler invoke the bundled Bash adapter with Bash-compatible `PLUGIN_ROOT` expansion.
- Strengthen deterministic manifest coverage so Windows hook commands must resolve through the supplied plugin root and cannot regress to PowerShell environment syntax inside Bash.
- Preserve the existing event set, `^Bash$` matcher, adapter behavior, shared drift classification, Claude/Caveman hook independence, and manual fallback.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `codex-lifecycle-hooks`: Require bundled lifecycle handlers to resolve and start correctly on Windows when Codex supplies `PLUGIN_ROOT`, including delivery of qualifying `PostToolUse` drift context.

## Impact

The change affects the bundled Codex hook configuration and its deterministic packaging/launcher tests. It changes no public API, state format, classifier semantics, dependencies, matcher behavior, Claude hook configuration, or unrelated plugin hook execution.

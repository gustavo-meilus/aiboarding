## Why

AIBoarding skills already run under Codex, but lifecycle nudging remains Claude-specific even though Codex now supports native plugin-bundled hooks. Codex users therefore miss maintained drift signals, startup checks, and minimal subagent context unless they remember the manual update workflow.

## What Changes

- Ship trusted, plugin-bundled Codex hooks for supported session, subagent, and tool lifecycle events.
- Add Codex-native drift nudging that reuses the same deterministic drift classifier and state contract as Claude lifecycle behavior.
- Keep startup checks silent for valid managed layouts and send spawned agents only a short `AGENTS.md` pointer, never duplicated onboarding content.
- Isolate Codex event and output translation from runtime-neutral lifecycle decisions.
- Keep all skills usable without hooks and document the explicit manual-lifecycle fallback when hooks are unavailable, disabled, or untrusted.
- Update plugin capability claims and verification only when the corresponding Codex behavior is shipped and reproducible.
- Preserve existing Claude Code hooks and cross-agent skill behavior.

## Capabilities

### New Capabilities

- `codex-lifecycle-hooks`: Codex-native lifecycle packaging, event adaptation, drift signals, silent startup checks, minimal subagent pointers, fallback behavior, and verifiable capability declarations.

### Modified Capabilities

None.

## Impact

Affected areas include `.codex-plugin/plugin.json`, new Codex hook packaging and adapters, runtime-neutral lifecycle/drift helpers under the existing template/tool ownership, create/update runtime-awareness guidance, hook and manifest tests, and the live-runtime verification runbook. No new dependency or public data migration is expected; existing Claude hook configuration and portable `SKILL.md` operation remain compatible.

## Why

`update-agent-onboarding` can currently advance `last_synced_commit` after an agent incorrectly judges a delta irrelevant, permanently removing onboarding-relevant commits from later drift windows. Pointer advancement needs deterministic evidence strong enough to preserve drift-on-uncertainty while retaining silent handling for proven bookkeeping and operationally irrelevant changes.

## What Changes

- Classify changed paths into provably irrelevant, potentially relevant, and definitely relevant evidence before semantic triage.
- Require applicable onboarding review or section revalidation for mechanically recognizable high-signal surfaces such as dependency/runtime manifests, build and test entry points, CI, runtime, schema, migration, and architecture-defining files.
- Allow semantic analysis to escalate low-risk deltas, but never downgrade deterministic high-risk evidence to a silent no-op.
- Permit pointer-only advancement only when every changed path is proven irrelevant and the sync pointer is valid.
- Preserve targeted section updates, content approval, malformed/rebased-pointer repair behavior, and onboarding-only loop suppression.
- Record classification evidence and outcome in operational sync state for later diagnosis.
- Replace filename-based default ignores for potentially authoritative files with narrower, configurable ignored and high-risk path rules.

## Capabilities

### New Capabilities

- `onboarding-drift-classification`: Evidence-based classification and safe state advancement for onboarding drift windows.

### Modified Capabilities

None.

## Impact

Affected surfaces include the `update-agent-onboarding` skill and distributed copies, drift hook classification, `.aiboarding/config.json` and operational state contracts, create/migration lifecycle guidance, regression fixtures, hook tests, and verification documentation. Existing repositories remain compatible: absent new configuration uses safe defaults, existing state remains readable, and no onboarding content changes without current approval semantics.

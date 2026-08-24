## Why

AIBoarding can advance `last_synced_commit` or report a lifecycle result without preserving the evidence that justified that decision. Durable, compact provenance is needed so maintainers and automation can distinguish a supported decision from an unexplained pointer value without loading transcripts or diagnostic logs.

## What Changes

- Record machine-readable evidence for meaningful drift classifications, deterministic onboarding validation, compression preservation checks, and available live-runtime verification.
- Bind each evidence record to the relevant repository commit or commit range, verification type, result, and runtime identity where applicable.
- Keep historical evidence separate from canonical operational state and outside always-loaded onboarding context.
- Redact or omit secrets, conversational transcripts, and high-volume raw logs.
- Make state advancement conditional on required validation, while treating non-critical historical evidence write failure as an explicit degraded outcome that cannot corrupt canonical state.
- Preserve the existing `state.json` shape and line-oriented hook-read contract during rollout.

## Capabilities

### New Capabilities

- `onboarding-verification-evidence`: Defines compact lifecycle evidence records, their safety and repository-binding rules, and their relationship to operational state advancement.

### Modified Capabilities

None.

## Impact

- Affects onboarding create/update/compression/audit workflows, live-runtime verification integration, lifecycle state handling, portable templates, and focused fixtures.
- Adds a durable evidence surface for humans, agents, CI, and debugging tools without adding a service or heavyweight dependency.
- Existing `state.json` consumers and hook readers continue to operate unchanged; rollout must remain safe across mixed versions and support rollback without losing canonical state.

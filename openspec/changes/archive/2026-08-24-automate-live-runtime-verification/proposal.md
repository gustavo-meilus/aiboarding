## Why

AIBoarding's critical runtime contract is protected only by manual protocols, so native onboarding loading and lifecycle delivery can regress when supported agent runtimes change. Reproducible live tests are needed to turn those assumptions into externally evaluated evidence without replacing the fast deterministic suite.

## What Changes

- Add an isolated live-runtime harness with Codex CLI as the selected live-acceptance runtime; retain Claude Code coverage as deterministic/manual only.
- Verify native onboarding loading with generated canaries and paired positive and broken-or-absent negative controls.
- Observe applicable subagent and lifecycle hook delivery, including required silence, through structured events, hook-owned evidence, process status, and filesystem state.
- Record runtime identity, runtime version, repository commit and cleanliness, protocol inputs, raw evidence locations, verdicts, and degraded reasons in machine-readable results.
- Fail closed when a runtime is missing, incompatible, produces malformed evidence, invokes an unapproved observation path, or cannot prove an expected result; reserve explicit degraded results for declared optional capabilities.
- Run live protocols separately from deterministic tests, with opt-in local execution and credential-aware scheduled or manual CI cadence.
- Retain and label manual runbook protocols that cannot yet be automated reliably.

## Capabilities

### New Capabilities

- `live-runtime-verification`: Isolated, externally adjudicated Codex CLI acceptance protocols for onboarding loading and lifecycle events, with Claude Code explicitly partial/manual.

### Modified Capabilities

None.

## Impact

Affected areas include a new live-test harness and scratch fixtures, runtime-specific protocol adapters, evidence schemas and ignored artifact paths, `docs/VERIFICATION.md`, README verification claims, and a credential-gated scheduled or manually dispatched GitHub Actions workflow. The change coordinates with `add-native-codex-lifecycle-hooks` for Codex hook protocols and `gate-aiboarding-changes-on-executable-verification` for CI ownership, while preserving `tests/run.sh`, existing hook contract tests, and manual verification procedures. No product dependency, onboarding format, or data migration is expected.

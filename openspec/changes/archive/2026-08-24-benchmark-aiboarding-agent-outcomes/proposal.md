## Why

AIBoarding's maintained context has structural and runtime verification, but no controlled evidence that it improves coding-agent outcomes or that compression savings justify any quality loss. A falsifiable benchmark is needed before the roadmap can support evidence-based claims.

## What Changes

- Add a reproducible benchmark matrix comparing no onboarding, minimal manual guidance, current AIBoarding output, supported compression levels, stale and contradictory onboarding, and naive truncation where applicable.
- Add representative tasks whose outcomes depend on repository commands, architecture boundaries, domain invariants, known failure modes, escalation rules, and nested or local instructions.
- Grade repository state, commands, tests, and invariant violations deterministically wherever possible, while labeling inferential judgments separately.
- Run controlled repeated trials when nondeterminism matters and retain trial-level traces, environment identities, grader outputs, costs, and aggregate uncertainty.
- Publish unfavorable, incomplete, and harmful-context results without suppression, and keep cost-bearing live evaluation outside the ordinary fast test path.

## Capabilities

### New Capabilities

- `agent-outcome-benchmarking`: Defines benchmark conditions, task and grader contracts, controlled execution, evidence retention, metrics, aggregation, and honest reporting for onboarding effects.

### Modified Capabilities

None.

## Impact

Affected surfaces include benchmark fixtures and manifests, an isolated runtime harness, objective graders, result schemas and retained artifacts, aggregate report generation, verification documentation, and an explicit cost-bearing workflow. The design should reuse the planned live-runtime result contract, mutation scenarios, compression outputs and receipts, and existing dependency-free test conventions where their ownership fits; it must not make authenticated benchmark runs part of `tests/run.sh` or add a general model-ranking framework.

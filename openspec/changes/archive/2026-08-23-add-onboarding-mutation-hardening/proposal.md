## Why

AIBoarding proves that selected syntax survives compression, but that does not show whether its complete verification system catches onboarding changes that preserve syntax while reversing meaning or removing required behavior. A maintained mutation corpus is needed to expose both detected defects and actionable verification gaps without overstating semantic correctness.

## What Changes

- Add realistic onboarding mutation operators covering verification removal, guardrail weakening or reversal, architecture direction, runtime/version guidance, escalation removal, cross-file contradictions, nested instruction conflicts, and instruction-chain budget failures.
- Exercise applicable mutations against compression outputs and general onboarding audit scenarios while preserving ordinary positive fixtures.
- Record each mutant as killed or surviving, identify every detecting sensor, and keep computed and inferred results distinct.
- Emit a reproducible report with corpus totals, non-trivial mutation score, per-mutant outcomes, and visible survivors.
- Retain mechanical command-preservation mutants as compatibility checks, but exclude trivial syntax-only kills from the primary score so they cannot inflate semantic detection coverage.

## Capabilities

### New Capabilities

- `onboarding-mutation-verification`: Defines the maintained harmful-mutation corpus, execution and evidence model, scoring rules, and reproducible reporting contract.

### Modified Capabilities

None.

## Impact

Affected surfaces include onboarding audit and compression verification fixtures, test harness commands, mutation corpus data, report generation, and verification documentation. The work builds on the computed-versus-inferred audit boundary planned by `make-onboarding-audit-evidence-aware`; current preservation tools, positive compression fixtures, and compatibility guarantees remain valid. No product API or target-repository source mutation is introduced.

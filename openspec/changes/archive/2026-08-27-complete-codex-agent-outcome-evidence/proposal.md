## Why

The retained Codex benchmark covers only one command-discovery task, two conditions, and two passing repetitions, so it cannot determine whether active AIBoarding helps, harms, or leaves Codex outcomes materially unchanged. The existing `agent-outcome-benchmarking` specification already defines the complete contract; this change finishes its maintained Codex evidence path without creating a second benchmark system.

## What Changes

- Retain the interrupted `codex-maintained-outcomes-v2` through `v6` runs as incomplete historical evidence, and add a frozen 12-cell `v7` smoke profile covering all six task categories under `none` and `aiboarding-full` once each.
- Complete the existing task packs and condition bundles so the shared runner can execute each declared profile cell from fresh controlled state and grade it independently.
- Connect the existing evidence validation, offline regrading, metrics, aggregation, report, and packaging primitives into one explicit profile-driven live and offline workflow.
- Retain one incomplete 12-cell Codex smoke result and its staged offline report; keep it unpublished because fail-closed packaging rejects incomplete evidence.
- Add deterministic contract and end-to-end tests for profile completeness, controlled-variable identity, fail-closed evidence handling, offline regeneration, and retained package integrity.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. This change implements the existing `agent-outcome-benchmarking` requirements without changing their behavior, so `.openspec.yaml` opts out of a redundant spec delta.

## Impact

- Affects `benchmarks/agent-outcomes/` task packs, condition artifacts, experiment profiles, runner/post-processing flow, retained Codex results, and benchmark documentation.
- Extends deterministic benchmark tests under `tests/benchmarks/` while preserving the rule that `bash tests/run.sh` never invokes authenticated Codex.
- Preserves existing experiment, condition, grader, and evidence identities; historical partial results remain incomplete, while the lean smoke run receives its own explicit `v7` profile and result identity.
- Adds no dashboard, service, database, external analytics integration, or runtime dependency.

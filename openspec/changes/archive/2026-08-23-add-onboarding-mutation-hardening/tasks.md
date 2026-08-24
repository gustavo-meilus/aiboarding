## 1. Corpus and Sensor Contracts

- [x] 1.1 Confirm the deterministic audit command and `computed`/`inferred` finding contract from `make-onboarding-audit-evidence-aware` are available, then add only thin mutation sensor adapters; verify the prerequisite audit fixtures and adapter status/provenance checks pass without duplicating validator logic.
- [x] 1.2 Add a stable mutation manifest plus isolated positive and mutant fixtures for verification removal, guardrail weakening and reversal, protected command change, architecture direction, runtime/version, cross-file contradiction, escalation removal, nested conflict, and instruction-chain budget; verify every fixture records source, operator, applicability, harm, sensor set, and scoring class.
- [x] 1.3 Add corpus validation for unique IDs, required fields/files, valid classifications, and required operator coverage; verify focused negative cases reject missing metadata, arbitrary-noise entries, duplicate IDs, missing positive controls, and absent required categories.

## 2. Mutation Execution and Evidence

- [x] 2.1 Implement computed mutation execution using existing preservation, budget, and deterministic audit sensors; verify positive controls pass, protected command mutation is killed mechanically, an over-budget nested chain is killed with its chain identified, and sensor failures cannot be counted as kills.
- [x] 2.2 Add the public audit-based inferred review protocol and normalized evidence record with corpus fingerprint, skill revision, runtime/model identity, outcome, category, and locations; verify missing, malformed, and stale inferred evidence make the run incomplete instead of becoming a pass or survivor.
- [x] 2.3 Exercise semantic challenge fixtures through the inferred protocol; verify required-verification removal and cross-file contradiction are killed, guardrail/architecture/runtime/escalation/nested-conflict results remain attributable to their seeded defects, and any undetected case is recorded as a survivor.

## 3. Scoring, Reporting, and Compatibility

- [x] 3.1 Add aggregation and stable report output with corpus identity, applicable totals, killed mutants, survivors, per-sensor provenance, and actionable gaps; verify exact report fixtures cover one mutant killed by multiple sensors, non-applicable exclusion, survivor rendering, and distinct all-killed, survivor, and incomplete exit statuses.
- [x] 3.2 Compute the primary score from applicable challenge mutants only and report syntax-baseline results separately; verify protected-command kills do not change the challenge numerator or denominator and the report includes the maintained-corpus limitation.
- [x] 3.3 Emit the maintained canonical mutation report and document exact computed, inferred, aggregation, refresh, and interpretation commands in `docs/VERIFICATION.md`; verify a rerun reproduces computed outcomes and score arithmetic while retaining separately identified inferred evidence.
- [x] 3.4 Run focused mutation and report tests, existing preservation and size-budget tests, the evidence-aware audit tests, and `tests/run.sh`; verify ordinary positive fixtures and all current preservation guarantees remain unchanged.

## 1. Evidence Contract and Writer

- [x] 1.1 Add the versioned common envelope and allowlisted fixtures for drift classification, onboarding validation, compression verification, and live-runtime verification; verify every valid fixture parses as JSON and focused negative fixtures reject missing identity/commit/type/result fields, unknown detail fields, local absolute paths, and sensitive/raw-log content.
- [x] 1.2 Add the minimal installed evidence writer for `.aiboarding/evidence/v1/` using stable semantic IDs, Git-derived filenames, same-directory temporary writes, and no-overwrite collision checks; verify focused tests cover first write, identical retry, conflicting retry, interrupted write, unwritable destination, and preservation of prior evidence and `state.json`.
- [x] 1.3 Install the writer through create and migrate workflows without eagerly creating history, update portable tool/plugin manifest checks, and document direct lookup by `last_synced_commit`, type, and outcome; verify new and mixed-version fixture installations expose the tool while existing state-only repositories still pass current hook reads.

## 2. State-Safe Lifecycle Recording

- [x] 2.1 Preserve the existing `state.json` shape and `_lib:json_get` contract, and add an evidence-only commit-range case to `test-drift-check.sh`; verify old state without evidence remains readable and `.aiboarding/evidence/v1/*` alone produces no drift nudge.
- [x] 2.2 Reconcile `update-agent-onboarding` with the shipped drift-classification result contract and record no-op/revalidated/relevant outcomes before state advancement; verify cases for proven no-op and relevant content update identify the exact base/head, path dispositions, affected sections, and validators while `AGENTS.md`/`CLAUDE.md` preservation and approval behavior remain unchanged.
- [x] 2.3 Enforce evidence-first, `HEAD`-recheck, state-last sequencing in onboarding update flows; verify simulated evidence-write failure and concurrent `HEAD` movement leave `last_synced_commit` unchanged, while a successful retry creates one evidence record and advances only to its evidenced head.
- [x] 2.4 Record create/update deterministic validation results from the maintained validator contracts without copying raw output; verify passing validators are associated with the content decision and failed or indeterminate validation records a compact failure when possible but never advances canonical state.
- [x] 2.5 Extend compression to record subject identity, level, measurements, and preservation/size outcomes while continuing the current `state.json:receipts` write during compatibility; verify compression pass, preservation failure, identical retry, old `audit-agent-onboarding --stats`, and unchanged legacy receipts.

## 3. Existing Evidence Producer Integration

- [x] 3.1 Import the machine-readable computed/inferred audit result contract only from state-owning create/update workflows, leaving standalone audit read-only; verify an update record names decisive validator provenance and standalone audit creates no `.aiboarding/evidence` file.
- [x] 3.2 Import sanitized live `result.json` or `summary.json` output after the live-runtime harness contract is available; verify successful and degraded runtime cases record runtime identity/version, protocol, source commit, verdict, and decisive hashes without prompts, credentials, environment dumps, or raw streams.
- [x] 3.3 Keep runtime-history persistence non-critical and independent from onboarding state; verify a forced import/write failure reports evidence-recording degradation while preserving the authoritative runtime verdict, `state.json`, onboarding files, and earlier evidence.

## 4. Migration and Acceptance Proof

- [x] 4.1 Exercise additive migration and rollback fixtures: state-only repository, repository with legacy compression receipts, evidence-aware mixed-version repository, optional receipt import retry, and evidence-aware writer removal; verify no existing data is deleted and old hooks/skills continue from preserved `state.json`.
- [x] 4.2 Run the focused acceptance matrix for no-op, relevant update, compression pass/fail, failed required verification, successful/degraded live runtime, evidence-only drift, retry, and write failure; inspect resulting records to prove each remains compact, machine-readable, repository-bound, and sufficient to explain any pointer advance.
- [x] 4.3 Run task-relevant shell tests, full `bash tests/run.sh`, plugin/manifest validation, and `openspec validate record-onboarding-verification-evidence --strict`; fix only task-scoped failures and record any integration deferred because its owning pending change is not yet applied.

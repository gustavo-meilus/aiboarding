## 1. Regression Contract

- [x] 1.1 Extend `tests/benchmarks/test-agent-outcomes-contracts.sh` with deterministic coverage for a valid v3 profile, individually corrupted task, condition, and grader hashes, combined corruption, sealed artifact-content drift, and one v1/v2/v3 invariant check; verify the focused test exposes the current v3 acceptance defect without invoking Codex.

## 2. Shared Integrity Fix

- [x] 2.1 Route every supported profile that declares sealed hashes, including v3, through the existing task/condition/grader SHA-256 validation while retaining version-specific non-integrity rules; verify `bash tests/benchmarks/test-agent-outcomes-contracts.sh` passes and valid legacy, v1, and v2 behavior remains unchanged.
- [x] 2.2 Correct the diagnostic/package wording in `docs/VERIFICATION.md` to describe regeneration and inspection of the unpublished diagnostic gate; verify it matches the offline output produced by the maintained diagnostic command.

## 3. Completion Verification

- [x] 3.1 Run `bash tests/run.sh`, confirm no authenticated or model-backed operation starts, and inspect the final diff for unrelated changes or altered fingerprint, historical-evidence, incomplete-evidence, publication, runtime, cost, or comparison-gate semantics.

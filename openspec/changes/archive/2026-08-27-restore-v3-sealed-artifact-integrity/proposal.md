## Why

Benchmark profile v3 accepts experiments without verifying that their declared task, condition, and grader SHA-256 values match the selected artifacts. This permits sealed artifacts to change under the same frozen experiment identity, weakening reproducibility and provenance guarantees already enforced for earlier sealed profiles.

## What Changes

- Require every supported profile that declares sealed artifact hashes, including v3, to validate task, condition, and grader content against those hashes before the experiment is accepted.
- Fail deterministically when any declared sealed hash is corrupted or when sealed artifact content changes without a matching manifest update.
- Preserve valid v1 and v2 behavior, legacy profile behavior that does not declare the sealed-hash contract, experiment fingerprint semantics, historical evidence, and existing execution/publication controls.
- Add offline regression coverage for individual and combined hash corruption, artifact-content drift, and the cross-version sealed-artifact invariant.
- Correct the maintained diagnostic wording in `docs/VERIFICATION.md` so it describes the diagnostic gate actually produced rather than publication/package output.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `agent-outcome-benchmarking`: Require all supported benchmark profiles that declare sealed hashes to prove task, condition, and grader artifact integrity before acceptance or live execution.

## Impact

- Affects benchmark manifest validation, deterministic benchmark contract tests, and diagnostic verification documentation.
- Invalid v3 manifests that previously passed validation will fail closed; valid supported profiles remain compatible.
- Adds no hashing mechanism, dependency, authenticated operation, or live Codex execution.

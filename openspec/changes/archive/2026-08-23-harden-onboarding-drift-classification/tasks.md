## 1. Deterministic Classification

- [x] 1.1 Add the self-contained `skills/update-agent-onboarding/classify-drift` companion with valid-range checks, three path categories, explicit precedence, stable reports, and final routing; verify a focused tool test covers definitely relevant manifests/build-test-CI-runtime-schema-migration-architecture surfaces, potentially relevant source/docs, configured irrelevant paths, malformed and rebased pointers, mixed deltas, and incomplete reports.
- [x] 1.2 Add `high_risk_paths` to the config contract, narrow exact always-ignored bookkeeping paths, and remove filename-based authoritative files from template ignores; verify tests show high-risk patterns beat ignored patterns while `AGENTS.md`, `CLAUDE.md`, and state-only ranges remain irrelevant.
- [x] 1.3 Add the regression where a high-risk manifest delta is paired with semantic no-op input and verify the classifier still returns mandatory revalidation; also verify semantic analysis can escalate a potential delta and can authorize no-op only with complete section evidence.

## 2. Hook and Workflow Integration

- [x] 2.1 Update `templates/hooks/drift-check` to consume the installed classifier, nudge on potential, definite, invalid, mixed, missing-tool, and malformed-report outcomes, and remain silent only for in-sync or proven-irrelevant ranges; verify `tests/hooks/test-drift-check.sh` preserves issue #1 onboarding-only regressions and covers default `README.md`, custom ignore, high-risk overlap, malformed pointer, rebased pointer, and mixed delta behavior.
- [x] 2.2 Update `skills/update-agent-onboarding/SKILL.md` to run deterministic classification before semantic triage, require section evidence, enforce mandatory high-risk revalidation, preserve targeted byte-identical sections and content approval, and recheck `HEAD` before writing; verify the documented branches map every classifier route to one unambiguous workflow outcome.
- [x] 2.3 Extend the state write contract with a backward-compatible `last_drift_classification` receipt and same-`HEAD` pointer coupling while preserving unknown fields; verify modern fixtures remain valid JSON and existing pointer readers return the same value with and without the new receipt.

## 3. Installation and Compatibility

- [x] 3.1 Update create and migration skills to copy the classifier companion into `.aiboarding/tools`, and update plugin manifest tests to require the canonical and installable files; verify `tests/plugin/test-manifests.sh` passes.
- [x] 3.2 Add the one-time managed classifier/drift-hook refresh path for existing Claude installations, with missing assets failing toward revalidation and no config or onboarding rewrite; verify an old-layout fixture upgrades idempotently and rollback leaves old readers able to consume state/config.
- [x] 3.3 Update verification and user guidance with category meanings, configuration precedence, diagnostic receipt fields, post-upgrade refresh, rollback, and the expanded issue #1 matrix; verify documented commands and paths resolve in the repository.

## 4. Acceptance Verification

- [x] 4.1 Run the focused classifier, hook, state, and manifest tests and verify all required definitely relevant, potentially relevant, provably irrelevant, onboarding-only, malformed-pointer, rebased-pointer, mixed-delta, and semantic-non-downgrade cases pass.
- [x] 4.2 Run `bash tests/run.sh` and `openspec validate harden-onboarding-drift-classification --strict`; fix only task-relevant failures and verify both commands pass.

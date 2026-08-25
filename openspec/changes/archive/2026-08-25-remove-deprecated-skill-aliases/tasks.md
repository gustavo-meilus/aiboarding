## 1. Retire the Alias Skills

- [x] 1.1 Delete `skills/create-aiboarding/` and `skills/update-aiboarding/`, then verify neither directory is discoverable under `skills/`.
- [x] 1.2 Update `tests/plugin/test-manifests.sh` to require the five supported skills and explicitly reject both retired alias directories; run `bash tests/plugin/test-manifests.sh` and verify it passes.

## 2. Update Active Guidance

- [x] 2.1 Update `README.md` and `docs/VERIFICATION.md` so current catalog, usage, and layout guidance no longer presents the aliases as available, while documenting the direct canonical replacements; verify active documentation distinguishes migration guidance from untouched historical records.
- [x] 2.2 Replace the legacy-layout drift nudge's retired command with `migrate-aiboarding` in both `templates/hooks/drift-check` and `.aiboarding/hooks/drift-check`; run the focused drift-hook tests and verify the two hook copies are byte-identical.
- [x] 2.3 Search active skills, templates, hooks, tests, and current documentation for `create-aiboarding` and `update-aiboarding`; verify remaining occurrences are limited to explicit removal/migration assertions or historical and archived records.

## 3. Verification

- [x] 3.1 Run `bash tests/run.sh` and `bash tests/self-host/test-managed-repo.sh`; verify the full suite passes with the five-skill catalog and managed template-copy parity.
- [x] 3.2 Update the evidence-aware audit to validate command paths without arguments and exclude `tests/fixtures/` onboarding files; add focused regression coverage.
- [x] 3.3 Run `.aiboarding/tools/check-size-budget AGENTS.md`, the preservation checks, and the audit workflow; verify self-host onboarding remains within budget, preserves protected content, and reports no blocking findings.

## 1. Policy Regression Coverage

- [x] 1.1 Add mixed-risk before/default-output fixtures covering negation, mandatory and optional modality, authorization, escalation, security, destructive or irreversible actions, and ordered migration prerequisites; add a harness-discovered focused test that verifies each identified high-consequence block is byte-identical while ordinary prose is reduced, then run it and confirm the current policy contract fails.
- [x] 1.2 Extend the focused test with canonical `Agent Guardrails` and `Escalation - Ask the User When` sections, equivalent off-heading instruction blocks, and non-high-consequence architecture/domain controls; verify classification coverage is narrow and every existing protected span still passes `tests/tools/test-check-preservation.sh`.

## 2. Default Preservation and Explicit Opt-In

- [x] 2.1 Replace `compress-onboarding`'s clarity-cap guidance with complete-region classification and default verbatim preservation, including source location/category reporting; verify the focused policy test proves `full` and `ultra` do not authorize high-consequence rewriting and low-risk prose still follows the selected level.
- [x] 2.2 Add the separate per-operation, per-region explicit opt-in path without persisting consent, while retaining protected-span verification and final diff approval; verify focused contract cases cover no consent, subset consent, and unchanged unselected regions.
- [x] 2.3 Update `create-agent-onboarding` and `update-agent-onboarding` to invoke the new preservation contract without duplicating its rules or retaining the old `lite` cap; verify skill contract tests find one authoritative policy and no conflicting compression guidance.

## 3. Receipt and Stats Compatibility

- [x] 3.1 Add optional `high_consequence_regions` evidence to compression receipts and user-facing results, recording location, category, `preserved` or `rewritten` outcome, and explicit opt-in status without copying instruction text; verify receipt fixtures distinguish preserved, opted-in rewritten, and verified-empty results.
- [x] 3.2 Update `audit-agent-onboarding --stats` to render the optional evidence and show `not recorded` for legacy receipts; verify new and legacy receipt fixtures retain existing level, byte, line, date, and token output and old receipt shape remains accepted.

## 4. Integration Verification

- [x] 4.1 Run the focused compression-policy test, `tests/tools/test-check-preservation.sh`, `tests/plugin/test-manifests.sh`, and `tests/run.sh`; verify adversarial regions remain verbatim, ordinary compression remains available, existing byte-preservation behavior is unchanged, and no state migration or destructive contraction is required.

## Why

AIBoarding's per-file size check cannot prove that Codex will load a complete project-instruction chain. Codex applies `project_doc_max_bytes` to the applicable root-to-working-directory chain, so individually valid files can still produce truncated effective guidance.

## What Changes

- Add deterministic Codex project-instruction discovery and cumulative byte validation using Codex's documented root-to-working-directory, one-file-per-directory, precedence, fallback, empty-file, and configured-budget semantics.
- Report each over-budget endpoint with its applicable ordered chain, measured bytes, and effective Codex runtime limit without summing independent sibling chains.
- Keep AIBoarding's recommended per-file line and byte budgets as separate soft guidance; stop presenting a passing local file check as proof that the effective Codex chain fits.
- Integrate chain validation into the read-only audit and blocking onboarding validation paths.
- Add fixtures for root-only, nested passing, nested failing, sibling-independent, and custom runtime-budget cases.
- Reconcile this focused capability with the pending `make-onboarding-audit-evidence-aware` change so implementation reuses one deterministic audit command rather than introducing a second validator.

## Capabilities

### New Capabilities

- `codex-instruction-budget-validation`: Defines deterministic discovery, measurement, configuration, reporting, and audit/validation behavior for effective Codex project-instruction chains.

### Modified Capabilities

None.

## Impact

- Affects portable tooling under `templates/tools/`, `.aiboarding/config.json` budget semantics, audit and onboarding-validation skill contracts, installed tool lists, and focused shell fixtures.
- Clarifies existing `check-size-budget` output and documentation without removing its fast per-file sensor.
- Adds no model tokenization, automatic onboarding restructuring, runtime service, or heavyweight dependency.

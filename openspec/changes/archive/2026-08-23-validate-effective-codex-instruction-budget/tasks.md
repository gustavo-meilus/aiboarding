## 1. Configuration and Ownership

- [x] 1.1 Reconcile the pending evidence-aware audit work so implementation extends or creates exactly one deterministic audit command, then verify template and installed-tool inventories contain no parallel chain validator.
- [x] 1.2 Add `codex_project_doc_max_bytes` and configured fallback filenames to managed configuration while accepting `strict_max_bytes` as a legacy runtime-limit alias; verify default, explicit, managed, legacy, and invalid-value resolution with focused tests.

## 2. Codex Chain Validation

- [x] 2.1 Implement root-to-endpoint discovery with `AGENTS.override.md`, `AGENTS.md`, configured fallback precedence, empty-file skipping, and at most one selected file per directory; verify focused cases cover precedence and inactive candidates.
- [x] 2.2 Implement ancestor-only chain construction, exact per-file and cumulative byte measurement, sibling isolation, and runtime-limit comparison in the shared deterministic command; verify findings include endpoint, ordered chain, byte totals, limit, source, severity, and computed provenance.
- [x] 2.3 Add root-only, nested-within-budget, nested-over-budget, sibling-independent, and custom-budget fixtures; verify each asserts exact chain selection, totals, finding text, and exit status.

## 3. Workflow Integration

- [x] 3.1 Update `audit-agent-onboarding` to consume deterministic chain results and keep soft per-file findings distinct from Codex runtime failures; verify a repository with passing files but a failing combined chain produces a computed audit failure.
- [x] 3.2 Route create and update blocking validation through the same chain result and revise `check-size-budget` claims so local success does not prove whole-chain safety; verify skill-contract and tool tests cover both sensors.
- [x] 3.3 Update generated config, tool installation lists, README guidance, and compatibility fixtures to name AIBoarding recommendations separately from the configured/default Codex limit; verify plugin and template completeness tests pass.

## 4. Regression Proof

- [x] 4.1 Run the focused chain/config fixtures and full `tests/run.sh` gate; verify all deterministic, skill-contract, manifest, and lifecycle tests pass without audit writes.
- [x] 4.2 Run `openspec validate validate-effective-codex-instruction-budget --strict`; verify every acceptance scenario and artifact remains valid.

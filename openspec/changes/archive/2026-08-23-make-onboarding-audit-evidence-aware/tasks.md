## 1. Deterministic Audit Tooling

- [x] 1.1 Add a portable deterministic audit command with stable severity/provenance/category/location output and exit codes `0` (no FAIL), `1` (validation FAIL), and `2` (usage or operational error); verify focused fixtures distinguish all three statuses.
- [x] 1.2 Reuse `check-size-budget` and implement wrapper-integrity plus nested `AGENTS.md` chain checks; verify fixtures cover clean state, missing import, malformed fences, soft and strict file budgets, passing chains, and a chain over 32768 bytes.
- [x] 1.3 Implement conservative resolvers for supported explicit command references without executing referenced commands; verify fixtures cover valid and missing paths/scripts/targets plus ambiguous text that produces no computed failure.

## 2. Distribution and Audit Orchestration

- [x] 2.1 Add the deterministic command to AIBoarding tool installation and template-completeness checks; verify `tests/plugin/test-manifests.sh` passes and the create skill names the installed tool.
- [x] 2.2 Update `audit-agent-onboarding` with the complete computed/mixed/inferred classification, deterministic-first orchestration, operational-error handling, and per-finding provenance independent from severity; verify a checked mixed-report example contains both computed and inferred findings under existing FAIL/WARN/INFO ordering.

## 3. Regression Proof

- [x] 3.1 Run the focused deterministic audit tests and the full `tests/run.sh` gate; verify all tool, skill-contract, manifest, and existing lifecycle tests pass without onboarding-file writes.
- [x] 3.2 Run `openspec validate make-onboarding-audit-evidence-aware --strict`; verify the completed change remains valid against every acceptance scenario.

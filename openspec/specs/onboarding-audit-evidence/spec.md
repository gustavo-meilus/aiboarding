## Purpose

Defines trustworthy onboarding audits that distinguish repository-computed evidence from model-inferred review while preserving severity and read-only operation.

## Requirements

### Requirement: Findings expose independent severity and evidence provenance
Every audit finding SHALL include one severity value of `FAIL`, `WARN`, or `INFO` and one evidence provenance value of `computed` or `inferred`. Severity SHALL communicate impact and SHALL NOT imply evidence provenance.

#### Scenario: Mixed evidence at one severity
- **WHEN** an audit contains a computed warning and an inferred warning
- **THEN** the report labels both `WARN` and separately labels their provenance as `computed` and `inferred`

#### Scenario: Mixed report remains unambiguous
- **WHEN** deterministic validation and semantic review both produce findings
- **THEN** every reported finding displays its severity and provenance without requiring section placement or wording to infer either value

### Requirement: Deterministic validators are independently runnable
Mechanically enforceable onboarding checks SHALL be runnable outside an agent session using repository-distributed, dependency-light tooling. The tooling SHALL make success, detected validation failure, and invocation or environment error distinguishable through process exit status.

#### Scenario: Clean deterministic validation
- **WHEN** the validator runs against a repository with no deterministic audit failure
- **THEN** it exits with success status and emits no computed `FAIL` finding

#### Scenario: Deterministic validation failure
- **WHEN** the validator detects at least one mechanically proven invalid state
- **THEN** it emits a `computed` finding with category and location and exits with validation-failure status

#### Scenario: Validator cannot run correctly
- **WHEN** invocation is invalid or a required input cannot be inspected
- **THEN** the validator exits with a status distinct from both success and validation failure and does not present the operational error as an audit finding

### Requirement: Wrapper integrity is computed
The deterministic validator SHALL inspect `CLAUDE.md` wrapper state and SHALL report a computed `FAIL` when the required `@AGENTS.md` import is absent or AIBoarding marker fences are structurally invalid.

#### Scenario: Missing wrapper import
- **WHEN** a `CLAUDE.md` wrapper lacks the required `@AGENTS.md` import line
- **THEN** deterministic validation reports a `FAIL` finding with `computed` provenance

#### Scenario: Invalid marker fence state
- **WHEN** AIBoarding marker fences are unmatched, misordered, mismatched by identifier, or illegally nested
- **THEN** deterministic validation reports a `FAIL` finding with `computed` provenance and identifies the affected file and location

### Requirement: Size and instruction-chain budgets are computed
The deterministic validator SHALL enforce the existing onboarding file budget and SHALL compute every nested `AGENTS.md` leaf-to-root instruction-chain byte total against the configured Codex cap. Existing size severities SHALL be preserved.

#### Scenario: File exceeds soft size budget
- **WHEN** an audited onboarding file exceeds an existing soft line or byte budget but not the strict cap
- **THEN** deterministic validation emits a `WARN` finding with `computed` provenance and exits successfully unless another computed failure exists

#### Scenario: File exceeds strict size cap
- **WHEN** an audited onboarding file exceeds the existing strict byte cap
- **THEN** deterministic validation emits a `FAIL` finding with `computed` provenance and exits with validation-failure status

#### Scenario: Nested instruction chain exceeds cap
- **WHEN** the sum of applicable nested `AGENTS.md` files on any leaf-to-root chain exceeds 32768 bytes
- **THEN** deterministic validation emits a `FAIL` finding with `computed` provenance and identifies that chain

### Requirement: Command-reference failures are computed only when mechanically established
The deterministic validator SHALL emit a computed stale-command finding only when a command reference matches a supported unambiguous form and an authoritative repository or execution-environment source proves that its referenced path, script, target, or executable cannot resolve. References requiring interpretation SHALL remain eligible for inferred review and SHALL NOT be represented as deterministic proof.

#### Scenario: Missing repository command target
- **WHEN** an onboarding file references a supported explicit package script, build target, or repository-relative command path and its authoritative source proves that target absent
- **THEN** deterministic validation emits a `FAIL` stale-command finding with `computed` provenance and the source line

#### Scenario: Command validity is context dependent
- **WHEN** a command-like phrase cannot be parsed unambiguously or depends on an environment the validator cannot establish
- **THEN** deterministic validation emits no computed failure for that phrase and semantic review may report an `inferred` finding

### Requirement: Semantic review remains inference-aware
The audit skill SHALL use model review for contradictions, ambiguous or vague guardrails, missing contextual guidance, procedural leakage, architectural quality, and other interpretation-heavy properties. Such findings SHALL be labeled `inferred` unless a documented deterministic rule proves the specific property.

#### Scenario: Semantic contradiction
- **WHEN** two instructions appear contradictory but resolving their scope or intent requires interpretation
- **THEN** the audit reports any contradiction finding with `inferred` provenance

#### Scenario: Ambiguous guardrail
- **WHEN** a guardrail's adequacy or meaning depends on context
- **THEN** the audit reports any ambiguity or missing-context finding with `inferred` provenance

### Requirement: Audit orchestration preserves evidence boundaries
The audit skill SHALL run deterministic validation and semantic review as distinct phases, then render one severity-ordered report without changing the provenance produced by either phase. The audit SHALL remain read-only and retain recognizable existing audit categories and remediation handoffs.

#### Scenario: Deterministic and semantic findings coexist
- **WHEN** an invalid wrapper and an ambiguous guardrail exist in the same repository
- **THEN** the final report includes a computed wrapper finding and an inferred guardrail finding while ordering both by existing severity rules

#### Scenario: Audit does not modify findings or files
- **WHEN** the audit completes
- **THEN** it has not changed onboarding files and it offers the existing update or compression handoff appropriate to reported findings

### Requirement: Deterministic behavior has fixture proof
Each deterministic validator behavior SHALL have fixtures covering success and failure, including invalid wrapper state, file budget, instruction-chain budget, and supported unresolvable command references. Report fixtures SHALL include at least one output containing both computed and inferred findings.

#### Scenario: Focused deterministic fixtures run
- **WHEN** the deterministic validator test command runs
- **THEN** fixtures assert emitted severity, provenance, category, location, and exit-status behavior for each deterministic check

#### Scenario: Mixed report example is verified
- **WHEN** report-format fixtures run
- **THEN** a single expected report proves that computed and inferred provenance remain visible independently from severity


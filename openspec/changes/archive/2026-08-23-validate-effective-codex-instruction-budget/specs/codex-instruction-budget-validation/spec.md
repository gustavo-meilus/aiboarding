## Purpose

Defines deterministic validation of effective Codex project-instruction chains so AIBoarding can detect cumulative truncation risk without conflating local guidance with runtime limits.

## ADDED Requirements

### Requirement: Applicable project-instruction chains follow Codex discovery semantics
The validator SHALL evaluate project instructions from the resolved project root to each relevant repository endpoint in root-to-leaf order. In each directory it SHALL select at most one non-empty instruction file using Codex precedence: `AGENTS.override.md`, `AGENTS.md`, then configured fallback filenames in order. It MUST NOT include files outside that endpoint's ancestor chain or sum independent sibling branches.

#### Scenario: Root-only repository
- **WHEN** a repository contains one non-empty root `AGENTS.md` below the effective runtime budget
- **THEN** validation reports the root chain within budget using that file's exact byte count

#### Scenario: Nested chain within budget
- **WHEN** a nested endpoint selects non-empty root and descendant instruction files whose cumulative bytes remain within the budget
- **THEN** validation reports the ordered root-to-descendant chain within budget

#### Scenario: Override and fallback precedence
- **WHEN** a directory contains multiple supported instruction filenames or empty higher-precedence candidates
- **THEN** validation selects the first non-empty candidate in documented Codex precedence and excludes other candidates in that directory

#### Scenario: Sibling chains remain independent
- **WHEN** separate sibling directories contain instruction files
- **THEN** validation evaluates each sibling with its shared ancestor chain and never adds one sibling's bytes to the other sibling's total

### Requirement: Effective chain bytes are measured deterministically
For each relevant endpoint, the validator SHALL sum the exact byte lengths of selected project-instruction file contents on its applicable chain. It MUST NOT estimate model tokens or include unrelated global Codex-home instructions in the project-chain measurement.

#### Scenario: Nested chain exceeds runtime budget
- **WHEN** two individually valid instruction files form an applicable chain whose cumulative content bytes exceed the effective runtime budget
- **THEN** validation reports an over-budget condition with the endpoint, ordered selected files, cumulative byte count, and runtime budget

#### Scenario: Unrelated large sibling does not fail endpoint
- **WHEN** one sibling instruction file is large but is not an ancestor of another endpoint
- **THEN** that file's bytes do not affect the other endpoint's measured chain

### Requirement: Runtime and recommended budgets remain distinct
AIBoarding SHALL present its recommended per-file line and byte budgets as soft onboarding guidance distinct from the effective Codex `project_doc_max_bytes` runtime limit. Chain validation SHALL use an explicitly configured runtime budget when supplied and the documented Codex default of 32768 bytes otherwise, and SHALL identify which source supplied the limit.

#### Scenario: Default runtime budget
- **WHEN** no Codex runtime budget is configured for validation
- **THEN** chain validation uses 32768 bytes and labels it as the Codex default rather than an AIBoarding recommendation

#### Scenario: Custom runtime budget
- **WHEN** validation is configured with a runtime budget different from 32768 bytes
- **THEN** every chain is evaluated against that value and the report labels it as configured

#### Scenario: Soft budget exceeded without runtime failure
- **WHEN** one instruction file exceeds AIBoarding's recommended byte budget but its applicable chain remains within the effective Codex runtime limit
- **THEN** the report emits soft-budget guidance without claiming Codex truncation or chain failure

### Requirement: Findings identify actionable chain evidence
An over-budget finding SHALL include severity, evidence provenance, affected repository endpoint, ordered instruction-file chain, measured cumulative bytes, effective runtime limit, and limit source. Operational errors that prevent complete discovery or measurement MUST be distinguishable from a passing result.

#### Scenario: Over-budget evidence is complete
- **WHEN** an applicable chain exceeds the effective runtime limit
- **THEN** the finding is a computed failure and names all selected files in load order plus endpoint, measured bytes, limit, and limit source

#### Scenario: Discovery cannot complete
- **WHEN** the validator cannot inspect a required path or parse required budget configuration
- **THEN** it reports an operational error and does not present the repository as within budget

### Requirement: Audit and onboarding validation consume the deterministic result
The read-only audit and blocking onboarding validation workflows SHALL invoke the same deterministic chain validator. A passing per-file size check MAY remain a fast local sensor but MUST NOT be represented as proof that all effective Codex chains fit the runtime budget.

#### Scenario: Audit detects cumulative failure
- **WHEN** every instruction file passes its local check but one applicable combined chain exceeds the runtime budget
- **THEN** the audit includes the deterministic chain failure

#### Scenario: Onboarding validation detects cumulative failure
- **WHEN** onboarding generation or update validation produces an over-budget applicable chain
- **THEN** blocking validation does not report success until the chain fits or the configured runtime budget is deliberately changed

### Requirement: Chain semantics have focused fixture proof
Deterministic fixtures SHALL cover root-only, nested-within-budget, nested-over-budget, sibling-independent, and custom-runtime-budget repositories, including exact endpoint, chain, byte total, limit, and result assertions.

#### Scenario: Required fixture matrix runs
- **WHEN** the focused chain-validation test runs
- **THEN** all five required repository shapes assert discovery, measurement, budget source, finding content, and exit behavior

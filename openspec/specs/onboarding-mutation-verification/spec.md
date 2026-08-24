# onboarding-mutation-verification Specification

## Purpose

Measures whether AIBoarding verification detects realistic harmful onboarding mutations while preserving evidence boundaries, positive fixtures, and visible gaps.

## Requirements

### Requirement: Maintained corpus represents harmful onboarding mutations
The system SHALL maintain stable, reviewable mutants derived from valid onboarding scenarios. The corpus MUST cover removal of required verification, weakening or reversal of safety guardrails, protected command changes, architecture dependency-direction changes, runtime or version changes, contradictory instructions across applicable files, escalation removal, conflicting nested instructions, and effective instruction-chain budget failures. Each mutant MUST identify its source scenario, mutation operator, applicability, expected harm, and whether it is a syntax-baseline or non-trivial challenge mutant; arbitrary textual noise MUST NOT qualify.

#### Scenario: Corpus categories remain represented
- **WHEN** corpus validation runs
- **THEN** it confirms at least one applicable mutant for every required category and rejects mutants missing provenance, harm, applicability, or scoring classification

#### Scenario: Positive controls remain ordinary
- **WHEN** mutation verification runs over a scenario
- **THEN** its unchanged positive control remains available and must pass the applicable existing verification layers before mutant outcomes are scored

### Requirement: Applicable verification layers exercise each mutant
The mutation harness SHALL run every applicable computed sensor and SHALL provide a reproducible semantic-review protocol for every applicable inferred sensor. Compression scenarios MUST exercise preservation and semantic checks relevant to compression; general audit scenarios MUST exercise applicable repository-wide, cross-file, and nested-instruction checks. A mutant MUST be classified as killed only when at least one sensor reports the seeded defect, and otherwise MUST be classified as surviving.

#### Scenario: Required verification is removed
- **WHEN** a mutant removes a condition agents must verify before completion while leaving protected syntax valid
- **THEN** at least one applicable verification layer kills the mutant and the result identifies that sensor

#### Scenario: Guardrail meaning is weakened or reversed
- **WHEN** a mutant preserves commands and identifiers but weakens or reverses a protected guardrail
- **THEN** byte preservation alone does not establish equivalence and the applicable semantic sensor records whether it kills or survives the mutant

#### Scenario: Cross-file instructions contradict
- **WHEN** a mutant introduces contradictory applicable instructions across `AGENTS.md`, `CLAUDE.md`, `.claude/rules/*.md`, or nested `AGENTS.md` files
- **THEN** semantic verification kills the mutant and records the conflicting locations

#### Scenario: Protected command changes
- **WHEN** a compression mutant alters a protected command
- **THEN** the mechanical preservation sensor kills the mutant and existing preservation behavior remains unchanged

#### Scenario: Nested instruction chain exceeds the effective cap
- **WHEN** a mutant makes an applicable leaf-to-root Codex instruction chain exceed the configured effective byte cap
- **THEN** a computed budget sensor kills the mutant and identifies the over-budget chain

### Requirement: Computed and inferred evidence remain distinguishable
Every sensor result SHALL state whether its evidence is `computed` or `inferred`. Computed results MUST be reproducible from repository inputs and command versions; inferred results MUST record the review protocol and runtime or model identity needed to interpret the observation. Aggregation MUST NOT relabel inferred detection as computed or treat absence of an inferred finding as mechanical proof of equivalence.

#### Scenario: Multiple sensor types kill one mutant
- **WHEN** computed and inferred sensors both detect the same seeded defect
- **THEN** the mutant is counted once as killed while the report lists each sensor with its original evidence provenance

#### Scenario: Semantic sensor does not detect a defect
- **WHEN** an applicable inferred sensor emits no finding attributable to a seeded defect
- **THEN** the mutant remains a visible survivor unless another applicable sensor kills it

### Requirement: Reports expose outcomes and non-inflated scores
The system SHALL emit a reproducible mutation report containing corpus identity, total applicable mutants, killed mutants, surviving mutants, per-mutant outcome, detecting sensors, and evidence provenance. The primary mutation score MUST use only non-trivial challenge mutants as its denominator; syntax-baseline mutants necessarily killed by established mechanical checks MUST be reported separately and MUST NOT inflate that score. Non-applicable mutants MUST be identified and excluded from all scoring denominators.

#### Scenario: Report contains killed and surviving mutants
- **WHEN** a run includes at least one detected defect and at least one undetected defect
- **THEN** the report gives distinct killed and surviving counts, lists both outcomes by stable mutant identifier, and computes the challenge score from eligible mutants only

#### Scenario: Survivor remains actionable
- **WHEN** any mutant survives
- **THEN** the report names its operator, scenario, applicable sensors, and missing detection as an actionable verification gap rather than presenting the corpus as fully successful

#### Scenario: Report can be reproduced
- **WHEN** a maintainer reruns the documented mutation command against the recorded corpus and computed-sensor versions
- **THEN** the computed outcomes and aggregate calculations are reproducible, while any inferred rerun is separately identified rather than silently replacing its recorded evidence

### Requirement: Existing verification guarantees remain compatible
Mutation verification SHALL preserve current positive compression fixtures, byte-preservation guarantees, and ordinary audit fixtures. Adding adversarial scenarios MUST NOT weaken or replace behavioral benchmarks, and the corpus MUST NOT claim complete semantic correctness.

#### Scenario: Existing positive and preservation checks run
- **WHEN** the mutation suite and nearest existing verification gates run
- **THEN** ordinary positive fixtures still pass and established command, code-fence, URL, path, and size-budget failures retain their existing behavior

#### Scenario: Mutation score is interpreted narrowly
- **WHEN** a report is published or emitted
- **THEN** it states that the score measures detection over the maintained corpus and does not prove complete onboarding correctness

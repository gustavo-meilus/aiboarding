## ADDED Requirements

### Requirement: Cost-bearing maintained comparisons are diagnostic-gated
For a new or materially changed cost-bearing Codex experiment path, the maintained workflow SHALL require one bounded live diagnostic canary before a larger maintained comparison can be launched through that workflow. The frozen diagnostic manifest MUST identify exactly one task-condition-repetition cell and declare a maximum of one live trial before execution begins. The canary MUST use a controlled low-cost runtime identity, retain complete machine-readable terminal evidence, permit no automatic retry, and remain separate from ordinary deterministic repository tests. The diagnostic is mechanically viable when its cell has complete retained terminal evidence and an objective pass or objective fail verdict. Missing required output, retained evidence, runtime state, or grader input MUST classify the diagnostic as incomplete and block routine expansion. Historical diagnostic evidence MUST remain identifiable as diagnostic and unpublished and MUST NOT be mutated or silently promoted into a published result corpus.

#### Scenario: New maintained experiment starts with one canary
- **WHEN** a maintainer selects a new or materially changed cost-bearing Codex experiment through the maintained workflow
- **THEN** the first live command selects a frozen diagnostic manifest containing exactly one planned cell and a declared maximum of one live trial

#### Scenario: Complete objective failure remains diagnostically viable
- **WHEN** the canary terminates with complete retained evidence and an objective fail verdict
- **THEN** the gate classifies the runtime path as mechanically viable rather than infrastructure-incomplete

#### Scenario: Incomplete canary blocks expansion
- **WHEN** the canary lacks required retained evidence, runtime state, output, or grader input
- **THEN** the maintained workflow refuses to launch a larger comparison and retains the diagnostic material for diagnosis without retrying automatically

#### Scenario: Viable canary does not trigger comparison
- **WHEN** the canary has complete retained evidence and an objective pass or fail verdict
- **THEN** the diagnostic command completes without launching another live trial or comparison

#### Scenario: Historical diagnostics remain unchanged
- **WHEN** the one-cell maintained diagnostic is introduced
- **THEN** earlier diagnostic manifests and retained evidence remain readable under their original identities and stay unpublished

### Requirement: Maintained diagnostic runtime is controlled and economical
The maintained live diagnostic SHALL record and use `gpt-5.6-luna` with low reasoning effort, disabled web search, ignored unrelated user configuration, an ephemeral session, machine-readable JSONL events, no automatic retry, a bounded timeout, and the least sandbox authority required by its selected task. These controls MUST be part of the frozen experiment identity rather than inherited from an unspecified runtime default. Optional prompt-input inspection MAY be used before live execution for diagnosis, but experimental inspection output MUST NOT be required evidence or an authoritative correctness gate.

#### Scenario: Diagnostic identity is frozen
- **WHEN** the maintained diagnostic manifest is validated before live execution
- **THEN** it records `gpt-5.6-luna`, low reasoning effort, the controlled tool and configuration surface, the selected sandbox, the timeout policy, and zero retries

#### Scenario: Diagnostic invokes Codex
- **WHEN** the maintainer explicitly runs the diagnostic
- **THEN** Codex runs once with the frozen controlled runtime and emits retained JSONL evidence for independent local grading

#### Scenario: Prompt inspection is unavailable
- **WHEN** the optional experimental prompt-inspection command is unavailable or changes behavior
- **THEN** deterministic validation and the authoritative live diagnostic remain usable without it

## MODIFIED Requirements

### Requirement: Cost-bearing execution remains explicit
Authenticated or materially slow benchmark execution SHALL require an explicit command or dedicated workflow and SHALL remain separate from ordinary deterministic repository tests. The repository's fast test path MAY validate manifests, graders, aggregation, schemas, diagnostic-gate semantics, and fake-runtime fixtures, but MUST NOT launch paid or authenticated agents. A documented larger maintained comparison MUST require both a mechanically viable retained one-cell diagnostic and a separate explicit maintainer action. Existing full comparison profiles SHALL remain available only through explicit use, and a successful diagnostic MUST NOT start one automatically.

#### Scenario: Ordinary test suite runs
- **WHEN** a developer runs the standard local test command
- **THEN** deterministic benchmark contract tests may run but no paid or authenticated benchmark trial starts

#### Scenario: Maintainer requests live benchmark execution
- **WHEN** an authorized maintainer invokes a documented live benchmark profile
- **THEN** the harness records declared cost and runtime limits and produces trial evidence without changing the ordinary test contract

#### Scenario: Maintainer requests diagnostic live benchmark execution
- **WHEN** an authorized maintainer explicitly invokes the documented diagnostic benchmark profile
- **THEN** the harness records its declared one-trial bound and controlled runtime identity and executes at most that single retained trial

#### Scenario: Maintainer requests larger live benchmark execution
- **WHEN** an authorized maintainer explicitly invokes a documented larger comparison after a viable matching diagnostic
- **THEN** the harness launches only that requested comparison and existing incomplete-evidence packaging and reporting rules continue to apply

#### Scenario: Maintainer declines comparative execution
- **WHEN** a viable diagnostic exists but no larger comparison is explicitly requested
- **THEN** no additional cost-bearing live execution occurs

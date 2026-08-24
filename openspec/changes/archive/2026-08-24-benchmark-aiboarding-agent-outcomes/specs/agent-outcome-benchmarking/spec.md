## Purpose

Provides falsifiable, reproducible evidence about how maintained project onboarding and its compression trade-offs affect coding-agent task outcomes.

## ADDED Requirements

### Requirement: Benchmark conditions represent useful, absent, degraded, and misleading context
The benchmark SHALL define stable onboarding conditions for no project onboarding, minimal manually written guidance, current AIBoarding output, every relevant supported AIBoarding compression level, stale onboarding, contradictory onboarding, and naive truncation when truncation is applicable. Each condition MUST record how its context was produced and MUST preserve the task-independent meaning of the control; a condition MUST NOT be tuned after observing trial outcomes to favor AIBoarding.

#### Scenario: Complete comparison matrix is selected
- **WHEN** a benchmark run selects the maintained comparison profile
- **THEN** its manifest identifies every applicable required condition, the exact context artifact and generation provenance for each, and any inapplicable condition with a reason

#### Scenario: Harmful context performs worse
- **WHEN** stale, contradictory, truncated, or AIBoarding-generated context produces an unfavorable result
- **THEN** the trial and aggregate retain that result under the original condition without relabeling, suppression, or replacement

### Requirement: Tasks isolate onboarding-dependent behavior
Every benchmark task SHALL define its instruction, starting repository state, permitted environment, expected outcome, and graders independently of an agent's response. The maintained suite MUST include representative tasks for discovering correct build or test commands, respecting an architectural boundary, preserving a documented domain invariant, avoiding a known failure mode, recognizing an escalation condition, and applying nested or local agent instructions where supported. Tasks MUST be reviewable for whether onboarding can materially affect their outcome and MUST NOT require knowledge available only in an AIBoarding-specific label or benchmark implementation detail.

#### Scenario: Maintained task categories are validated
- **WHEN** task corpus validation runs
- **THEN** it confirms every required behavior category has at least one valid task with declared fixture state, expected outcome, applicable conditions, and grader contract

#### Scenario: Agent claims completion incorrectly
- **WHEN** an agent reports completion but the task's independent outcome graders fail
- **THEN** the trial records task failure and false completion regardless of the agent's self-assessment

### Requirement: Objective outcome grading has authority
The benchmark SHALL use deterministic graders wherever repository state, executable tests, command validity, architecture rules, domain invariants, or externally observable side effects can establish an outcome. Every grader MUST have a versioned definition that is unavailable to the tested agent during the trial unless the task explicitly declares otherwise, and reportable benchmark evidence MUST include enough of that definition to rerun grading independently. A task MAY use an inferential judge only for criteria that cannot be established mechanically; every such criterion MUST be labeled `inferred`, separated from objective pass or fail, and accompanied by its protocol and judge identity. Inferential output MUST NOT override a conflicting deterministic result.

#### Scenario: Repository outcome is mechanically decidable
- **WHEN** tests, file state, command records, or invariant checks can determine whether a task succeeded
- **THEN** a deterministic grader decides that criterion and the agent's prose and any inferential judge cannot change its verdict

#### Scenario: Inferential judgment is necessary
- **WHEN** a declared task criterion cannot be graded deterministically
- **THEN** the result identifies that criterion as inferred, records the judge protocol and identity, and reports it separately from objective outcomes

#### Scenario: Grader cannot produce required evidence
- **WHEN** an applicable grader errors, times out, encounters an unknown evidence shape, or lacks required input
- **THEN** the trial is incomplete rather than passed or failed by assumption

#### Scenario: Published result is independently regraded
- **WHEN** a reviewer obtains the published task definition, grader revision, and retained trial evidence
- **THEN** the reviewer can rerun objective grading without model access while the tested agent had no undeclared access to the grader during its trial

### Requirement: Comparisons hold non-context variables constant
For trials compared within an experiment, the harness SHALL hold model and version, agent harness and version, task revision, repository fixture, runtime environment, permissions, tools, budgets, timeout policy, and grader revisions constant except for the declared onboarding condition. Every run MUST record these identities. A change to any controlled variable MUST create a distinct experiment identity and MUST NOT be silently pooled with prior trials.

#### Scenario: Paired conditions execute
- **WHEN** two onboarding conditions are compared for a task
- **THEN** their trial records share the same declared controlled-variable identity and differ only in recorded experimental variables

#### Scenario: Harness changes between runs
- **WHEN** model, environment, permissions, budgets, tools, task, or harness behavior changes
- **THEN** aggregation separates the affected trials into a distinct experiment or marks the comparison invalid

### Requirement: Trials are isolated and repeatable
Each trial SHALL run from a fresh, declared repository and agent-session state without context, filesystem, process, or runtime-state leakage from another condition. The benchmark manifest SHALL define the run count and ordering policy. Conditions MUST run multiple trials when observed or expected nondeterminism materially affects interpretation, and repeated trials MUST retain distinct seeds or run identities rather than reuse cached outcomes.

#### Scenario: Repeated stochastic comparison runs
- **WHEN** a task and runtime are designated nondeterministic
- **THEN** every compared condition runs the declared number of fresh trials and aggregation reports the observed variation rather than only a selected run

#### Scenario: Trial starts after another condition
- **WHEN** the harness begins a new trial
- **THEN** it proves or records fresh fixture and session identities and does not reuse prior-condition outputs as evidence

### Requirement: Trial evidence supports independent inspection
Every trial SHALL retain a machine-readable manifest, sanitized agent transcript or event stream where available, attempted commands and tool calls, final repository state identity or diff, grader inputs and outputs, process statuses, timing data, token or context usage where measurable, retry events, and human interventions when the protocol permits them. Evidence MUST identify the source revision and condition artifact, preserve enough raw detail to recompute the verdict, and exclude credentials, runtime authentication state, and unrelated environment contents.

#### Scenario: Reviewer audits an aggregate result
- **WHEN** a reported task-condition result is inspected
- **THEN** it links to trial artifacts sufficient to trace the aggregate back to controlled inputs, agent actions, objective grader evidence, and final verdicts

#### Scenario: Usage metric is unavailable
- **WHEN** a runtime cannot expose token, context, elapsed-time, retry, or tool-call data reliably
- **THEN** the corresponding field is recorded as unavailable with a reason rather than as zero

### Requirement: Metrics distinguish success, harm, and cost
The benchmark SHALL compute task success, false-completion rate, architecture or guardrail violations, invalid commands attempted, tool calls, retries, and human interventions from declared trial evidence. It SHALL also report token or context usage and elapsed time where the runtime measures them meaningfully. Metric definitions, denominators, missing-data handling, aggregation rules, and any completion-claim or command-validity classifiers MUST be versioned and applied identically across compared conditions. A metric that cannot be classified reliably from the retained evidence MUST be recorded as unavailable with a reason; it MUST NOT be guessed or silently delegated to an inferential judge.

#### Scenario: Condition reduces tokens but harms correctness
- **WHEN** one compression condition uses fewer measured tokens but has lower task success or more violations
- **THEN** the report shows both the cost reduction and the quality loss without collapsing them into one favorable score

#### Scenario: Trial evidence records invalid action
- **WHEN** an agent attempts an invalid command or violates a declared boundary even if it later completes the task
- **THEN** the applicable violation metric records the event independently of final task success

#### Scenario: Evidence cannot support reliable classification
- **WHEN** retained runtime evidence cannot deterministically establish whether an agent claimed completion or attempted an invalid command
- **THEN** the affected metric is unavailable with a reason and is excluded from denominators that require an observed classification

### Requirement: Aggregates expose uncertainty and unfavorable evidence
Aggregate output SHALL include the full task-by-condition matrix, trial counts, missing or incomplete trials, per-metric summaries, and uncertainty or observed dispersion across repeated trials. Reports MUST separate measured facts from interpretation, MUST identify objective and inferred evidence, MUST show harmful and unfavorable AIBoarding outcomes, and MUST state that the benchmark does not establish universal coding-agent or foundation-model quality.

#### Scenario: Results vary across repeated trials
- **WHEN** repeated trials produce different outcomes
- **THEN** the aggregate reports counts and uncertainty or dispersion using the declared method and does not present one run as the condition's result

#### Scenario: AIBoarding loses a comparison
- **WHEN** no onboarding, manual guidance, stale context, truncation, or another condition outperforms an AIBoarding condition on any reported metric
- **THEN** the published matrix and interpretation retain the unfavorable comparison and its inspectable evidence

#### Scenario: Evidence set is incomplete
- **WHEN** required trials, controlled-variable identities, graders, or raw artifacts are missing
- **THEN** the report labels the affected comparison incomplete and excludes it from claims requiring complete evidence

### Requirement: Cost-bearing execution remains explicit
Authenticated or materially slow benchmark execution SHALL require an explicit command or dedicated workflow and SHALL remain separate from ordinary deterministic repository tests. The repository's fast test path MAY validate manifests, graders, aggregation, schemas, and fake-runtime fixtures, but MUST NOT launch paid or authenticated agents.

#### Scenario: Ordinary test suite runs
- **WHEN** a developer runs the standard local test command
- **THEN** deterministic benchmark contract tests may run but no paid or authenticated benchmark trial starts

#### Scenario: Maintainer requests live benchmark execution
- **WHEN** an authorized maintainer invokes the documented live benchmark profile
- **THEN** the harness records declared cost and runtime limits and produces trial evidence without changing the ordinary test contract

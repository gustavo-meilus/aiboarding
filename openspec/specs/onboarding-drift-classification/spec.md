## Purpose

Protect onboarding freshness by combining deterministic repository-change evidence with semantic review before operational sync state can discard a drift window.

## Requirements

### Requirement: Every valid drift delta receives deterministic evidence classification
The system SHALL classify every changed path in a valid `last_synced_commit..HEAD` range as provably irrelevant, potentially relevant, or definitely relevant before semantic onboarding analysis. Classification MUST cover the entire range, retain the signal that produced each definitely relevant result, and treat mixed deltas according to their highest-risk member.

#### Scenario: Dependency manifest is definitely relevant
- **WHEN** a valid delta changes a dependency or runtime manifest recognizable without repository-language assumptions
- **THEN** the system classifies that path as definitely relevant and identifies the manifest signal

#### Scenario: High-signal engineering surface is definitely relevant
- **WHEN** a valid delta changes a recognizable build, test, CI, runtime, schema, migration, architecture-defining, or equivalent high-signal surface
- **THEN** the system classifies that path as definitely relevant and requires review of applicable onboarding sections

#### Scenario: Ordinary source or documentation path is potentially relevant
- **WHEN** a changed path matches neither a definitely relevant signal nor an explicit irrelevant rule
- **THEN** the system classifies it as potentially relevant for semantic analysis

#### Scenario: Entire delta is operationally irrelevant
- **WHEN** every changed path is an onboarding bookkeeping path or matches an explicit irrelevant-path rule and no higher-priority signal matches
- **THEN** the system classifies the delta as provably irrelevant

#### Scenario: Mixed delta inherits highest risk
- **WHEN** a delta contains both irrelevant paths and at least one definitely relevant path
- **THEN** the system classifies the delta as definitely relevant and does not hide the high-risk path

### Requirement: Deterministic high-risk evidence cannot be semantically downgraded
The system MUST require applicable onboarding review or section revalidation for every definitely relevant delta. Semantic analysis MAY expand affected sections or escalate a potentially relevant delta, but MUST NOT convert a definitely relevant delta into a silent no-op.

#### Scenario: Semantic analysis says no-op despite manifest change
- **WHEN** deterministic classification finds a dependency or runtime manifest change and semantic analysis reports no onboarding impact
- **THEN** the system still revalidates the applicable stack, runtime, build, test, architecture, or verification sections before advancing state

#### Scenario: Semantic analysis escalates a low-risk change
- **WHEN** a potentially relevant delta semantically changes onboarding scope
- **THEN** the system routes the affected sections to targeted onboarding review

#### Scenario: High-risk review finds no content change
- **WHEN** required section revalidation finds existing onboarding content remains correct
- **THEN** the system may advance state with a recorded revalidated-no-content-change outcome without requesting content approval

### Requirement: Silent pointer advancement requires affirmative irrelevance evidence
The system SHALL advance `last_synced_commit` through the no-op branch only when the pointer range is valid, every path has been classified, no definitely relevant signal remains unreviewed, and the classification record contains affirmative evidence for the no-op outcome. A bare or malformed semantic conclusion MUST NOT authorize pointer advancement.

#### Scenario: Proven irrelevant range advances without content change
- **WHEN** a valid delta contains only paths proven operationally irrelevant
- **THEN** the system advances only operational sync state and leaves `AGENTS.md` and `CLAUDE.md` byte-identical

#### Scenario: Potentially relevant range receives evidence-backed semantic no-op
- **WHEN** all potentially relevant paths were examined against every onboarding section and the recorded analysis explains why no section changed
- **THEN** the system may advance state without changing onboarding content

#### Scenario: Unclassified path blocks no-op
- **WHEN** any changed path lacks a deterministic category or required semantic disposition
- **THEN** the system does not take the no-op branch and requires revalidation

### Requirement: Invalid sync state fails toward revalidation
The system MUST treat a missing, empty, malformed, or unresolvable sync pointer, including a rebased-away commit, as uncertain state that cannot take the no-op branch.

#### Scenario: Malformed pointer
- **WHEN** `last_synced_commit` is missing, empty, or malformed
- **THEN** the system requests full onboarding revalidation before reseeding operational state

#### Scenario: Rebased-away pointer
- **WHEN** Git cannot resolve the recorded pointer or construct its delta to `HEAD`
- **THEN** the system requests full onboarding revalidation rather than treating the empty result as irrelevant

### Requirement: Classification remains diagnosable
Every completed drift evaluation SHALL record, in operational sync state separate from onboarding content, the evaluated base and head commits, deterministic categories and matched signals, semantic disposition, affected or revalidated sections, and final outcome. Pointer advancement and its classification record MUST describe the same evaluated `HEAD`.

#### Scenario: No-op record explains state advancement
- **WHEN** the system advances a pointer without changing onboarding content
- **THEN** the committed operational record identifies the range, why each non-bookkeeping path was irrelevant, and whether the outcome was proven irrelevant or revalidated without content change

#### Scenario: Relevant record identifies review scope
- **WHEN** classification routes a delta to targeted onboarding review
- **THEN** the operational record identifies the deterministic and semantic evidence plus affected onboarding sections

### Requirement: Configuration is extensible and fail-safe
Repositories SHALL be able to add high-risk and ignored path patterns. Always-ignored onboarding bookkeeping paths MUST preserve loop suppression; otherwise, a high-risk match MUST take precedence over an ignored-path match. Default ignored paths MUST NOT suppress an authoritative file solely because its filename commonly denotes documentation, history, build, runtime, or usage information.

#### Scenario: Repository adds a high-risk path
- **WHEN** repository configuration marks a project-specific path as high-risk
- **THEN** changes to that path are definitely relevant and require applicable review

#### Scenario: Repository ignores an operational artifact
- **WHEN** repository configuration ignores a path that matches no high-risk rule
- **THEN** changes limited to that path may be classified as provably irrelevant

#### Scenario: Ignored and high-risk patterns overlap
- **WHEN** a non-bookkeeping path matches both ignored and high-risk configuration
- **THEN** the system treats it as definitely relevant

#### Scenario: Authoritative documentation filename changes under defaults
- **WHEN** a delta changes a default-named file such as `README.md` or `CHANGELOG.md` that may describe build, runtime, architecture, or usage
- **THEN** filename alone does not classify the file as irrelevant

### Requirement: Existing onboarding lifecycle behavior remains compatible
The system SHALL keep existing state readable when classification fields are absent, preserve content approval for onboarding edits, preserve targeted section updates and byte-identical untouched sections, and suppress drift for ranges containing only managed onboarding documents and operational bookkeeping.

#### Scenario: Existing state lacks classification metadata
- **WHEN** an existing repository has a valid `last_synced_commit` but no classification record
- **THEN** the next delta is classified normally without destructive state migration

#### Scenario: Onboarding-only bookkeeping range
- **WHEN** changes since the pointer affect only `AGENTS.md`, `CLAUDE.md`, or aiboarding-owned operational state and lifecycle files
- **THEN** drift detection remains silent and does not create a self-referential loop

#### Scenario: Targeted review changes content
- **WHEN** review determines one or more onboarding sections require edits
- **THEN** only those sections are proposed, all untouched sections remain byte-identical, and content is not written without existing user approval

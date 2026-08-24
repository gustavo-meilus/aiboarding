# high-consequence-compression-preservation Specification

## Purpose

Preserves the behavioral force of safety-critical onboarding instructions while allowing ordinary descriptive guidance to retain existing compression behavior.

## Requirements

### Requirement: High-consequence instruction regions are identified narrowly
The system SHALL classify the complete `Agent Guardrails` and `Escalation - Ask the User When` sections as high-consequence. It SHALL also classify the smallest complete instruction block needed to preserve context when content outside those sections governs security, authorization, approval or escalation, destructive or irreversible actions, or required ordering and prerequisites for destructive or migration operations. Ordinary project purpose, architecture description, domain explanation, and other descriptive prose MUST NOT become high-consequence solely because it is important or technical.

#### Scenario: Canonical guardrail and escalation sections
- **WHEN** an onboarding file contains `Agent Guardrails` or `Escalation - Ask the User When`
- **THEN** the complete section is classified as high-consequence regardless of the selected compression level

#### Scenario: Equivalent instruction outside canonical headings
- **WHEN** a paragraph, list item, warning, or ordered procedure outside the canonical sections prohibits an unauthorized action, defines an escalation condition, imposes a security constraint, or orders prerequisites before an irreversible operation
- **THEN** the complete instruction block and context needed to interpret it are classified as high-consequence

#### Scenario: Ordinary descriptive prose remains compressible
- **WHEN** content only describes project purpose, architecture, domain concepts, or routine operation without imposing a high-consequence behavioral constraint
- **THEN** the system applies the selected existing compression level normally

### Requirement: Default compression preserves high-consequence wording verbatim
The system SHALL exempt every identified high-consequence region from semantic rewriting by default and SHALL retain its source wording and order byte-for-byte. Compression level selection, including `full` or `ultra`, MUST NOT imply permission to rewrite such a region. Lower-risk content in the same file SHALL remain eligible for the selected compression level.

#### Scenario: Prohibition retains force
- **WHEN** source guidance says an agent MUST NOT perform an action
- **THEN** default compression preserves the complete high-consequence region verbatim and cannot turn the prohibition into a recommendation, preference, or optional action

#### Scenario: Required modality retains force
- **WHEN** source guidance uses mandatory or authorization-sensitive wording such as MUST, SHALL, required, only, or unless
- **THEN** default compression preserves that wording and its complete high-consequence region verbatim

#### Scenario: Destructive or migration order remains explicit
- **WHEN** source guidance requires approval, backup, verification, or another prerequisite before a destructive, irreversible, or migration step
- **THEN** default compression preserves the complete ordered instruction verbatim, including ordering terms and prerequisites

#### Scenario: Escalation and security conditions remain intact
- **WHEN** source guidance defines when to stop, ask, escalate, confirm authorization, or enforce a security boundary
- **THEN** default compression preserves the complete condition and required response verbatim

#### Scenario: Mixed-risk file still saves tokens
- **WHEN** a file contains both high-consequence instructions and lower-risk descriptive prose
- **THEN** the high-consequence regions remain verbatim while eligible lower-risk prose is compressed at the selected level

### Requirement: Stronger rewriting requires explicit scoped opt-in
The system SHALL identify the affected high-consequence regions and obtain an explicit user decision before semantically rewriting any of them. Consent MUST be scoped to identified regions in the current compression operation, MUST NOT be inferred from a compression level or ordinary final diff approval, and MUST NOT persist as a repository-wide default. Opted-in rewriting MUST still satisfy all existing byte-preservation requirements and retain unambiguous behavioral force.

#### Scenario: No opt-in is provided
- **WHEN** the user selects a compression level but does not separately authorize rewriting identified high-consequence regions
- **THEN** those regions remain verbatim

#### Scenario: User authorizes selected regions
- **WHEN** the system names the identified regions and the user explicitly authorizes stronger rewriting for a subset
- **THEN** only that subset is eligible for rewriting during the current operation and all other high-consequence regions remain verbatim

#### Scenario: Existing protected spans survive opted-in rewriting
- **WHEN** a user authorizes stronger rewriting of a high-consequence region
- **THEN** commands, paths, URLs, identifiers, code, and every other existing protected span remain byte-for-byte preserved

### Requirement: Reports distinguish preserved high-consequence content
Each compression result SHALL report the source locations or section names, classification categories, and outcome of identified high-consequence regions without duplicating their full content. Its receipt SHALL add equivalent structured evidence distinguishing `preserved` regions from explicitly opted-in `rewritten` regions. A receipt lacking this optional evidence SHALL be treated as a legacy receipt with preservation status not recorded, not as proof that no high-consequence content existed.

#### Scenario: Default preservation is visible
- **WHEN** default compression exempts one or more high-consequence regions
- **THEN** the user-facing result and receipt identify them as intentionally preserved rather than compressed

#### Scenario: Opted-in rewriting is visible
- **WHEN** a user explicitly authorizes rewriting an identified region
- **THEN** the result and receipt identify that region as explicitly opted-in and rewritten

#### Scenario: Legacy receipt is rendered
- **WHEN** stats are requested for a receipt written before high-consequence evidence existed
- **THEN** existing byte, line, level, date, and token information remains readable and high-consequence status is shown as not recorded

### Requirement: Existing compression compatibility remains intact
The system SHALL retain existing compression level names, ordinary low-risk behavior, approval gating, and byte-preservation checks. Adversarial validation SHALL cover negation, modality, ordering, authorization, escalation, security, and destructive-action wording and SHALL prove default outputs preserve identified high-consequence regions verbatim while still compressing eligible prose.

#### Scenario: Existing byte-preservation checks continue
- **WHEN** compression validation runs after this policy is introduced
- **THEN** established command, code-fence, URL, path, identifier, and code preservation cases retain their current behavior

#### Scenario: Adversarial default fixtures run
- **WHEN** focused compression tests exercise wording that could weaken through omitted negation, changed modality, reordered prerequisites, lost authorization, removed escalation, weakened security, or softened destructive-action constraints
- **THEN** every identified high-consequence source region matches the default output byte-for-byte and eligible descriptive fixture content remains compressed

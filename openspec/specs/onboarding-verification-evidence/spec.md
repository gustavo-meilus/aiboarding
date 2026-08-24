# onboarding-verification-evidence Specification

## Purpose

Preserve compact, inspectable proof for onboarding lifecycle decisions while keeping canonical sync state compatible, safe, and independent from historical evidence.

## Requirements

### Requirement: Lifecycle evidence has a compact machine-readable contract
The system SHALL represent each evidence event as a self-contained machine-readable record with a schema version, stable record identity, verification type, outcome, repository identity, relevant commit or commit range, and compact decisive details. Records MUST distinguish drift classification, onboarding validation, compression verification, and live-runtime verification without requiring consumers to infer the type from prose.

#### Scenario: Evidence record identifies its repository state
- **WHEN** a lifecycle workflow records evidence for a commit range
- **THEN** the record identifies the evaluated base and head commits, repository-relative subject where applicable, verification type, outcome, and schema version

#### Scenario: Consumer inspects evidence without onboarding context
- **WHEN** a human, agent, CI job, or debugging tool reads an evidence record
- **THEN** it can interpret the decisive result without loading `AGENTS.md`, a conversational transcript, or raw diagnostic logs

### Requirement: Pointer advancement has durable supporting evidence
The system MUST persist evidence that explains why advancing `last_synced_commit` to a particular commit was safe before writing that pointer. The evidence and pointer MUST refer to the same evaluated head commit, and the system MUST re-check repository head before advancement so a concurrent commit cannot be covered by stale evidence.

#### Scenario: Proven no-op advances state
- **WHEN** a valid range is classified as no onboarding impact and required checks pass
- **THEN** evidence records the base, head, classification outcome, decisive path dispositions, and passed checks before `last_synced_commit` advances to that head

#### Scenario: Relevant update advances state
- **WHEN** onboarding content changes after a relevant delta
- **THEN** evidence associates the updated commit range and affected content with every required validator that passed before the pointer advances

#### Scenario: Repository head changes during recording
- **WHEN** repository `HEAD` changes after verification but before pointer advancement
- **THEN** the system does not advance the pointer from that stale verification and requires the new range to be evaluated

### Requirement: Failed required verification cannot authorize canonical state
The system MUST treat failed or incomplete required verification as insufficient evidence for content acceptance or sync-pointer advancement. It SHALL record the failure when the evidence store remains writable and SHALL report evidence-recording failure separately from the verification failure.

#### Scenario: Deterministic validator fails
- **WHEN** a required onboarding validator returns a failing or indeterminate result
- **THEN** the system leaves canonical onboarding state unadvanced and records the validator identity and failure outcome without storing its full raw log

#### Scenario: Failure evidence cannot be written
- **WHEN** required verification fails and its non-critical historical failure record cannot be written
- **THEN** canonical state remains unchanged and the workflow reports both the verification failure and the evidence-write failure

### Requirement: Compression verification is attributable
The system SHALL record compression evidence that identifies the subject file, compression level, before-and-after measurements, preservation validator, preservation result, and relevant repository commit. Existing compression receipts MUST remain readable during the compatibility window.

#### Scenario: Compression preservation passes
- **WHEN** compressed onboarding content passes byte-preservation and applicable size checks
- **THEN** the resulting evidence identifies those validators and their outcomes alongside the compact compression measurements

#### Scenario: Compression preservation fails
- **WHEN** protected content is changed or another required compression validator fails
- **THEN** the system records a failed compression-verification outcome when possible and does not use that result to advance canonical sync state

### Requirement: Live-runtime evidence records protocol results without transcripts
The system SHALL accept available live-runtime verification evidence containing the source commit, protocol or case identity, runtime identity and version, verdict, and compact decisive references or hashes. Runtime evidence MUST NOT require or retain a conversational transcript to establish the lifecycle result.

#### Scenario: Runtime protocol passes
- **WHEN** a supported runtime protocol completes successfully
- **THEN** evidence records the runtime name and version, protocol identity, source commit, pass result, and compact decisive result metadata

#### Scenario: Runtime capability is unavailable
- **WHEN** a requested runtime protocol cannot run because a required capability is unavailable
- **THEN** evidence may record an explicit degraded or unavailable result but MUST NOT represent it as a pass

### Requirement: Evidence is separate from operational state and drift input
Historical evidence SHALL be stored separately from `state.json` and from always-loaded onboarding instruction files. Evidence-only changes MUST be classified as AIBoarding bookkeeping so recording them does not create onboarding drift or a self-referential update loop.

#### Scenario: Evidence-only commit lands
- **WHEN** commits since `last_synced_commit` change only the managed evidence surface
- **THEN** drift detection remains silent and does not request onboarding revalidation

#### Scenario: Existing hook reads state
- **WHEN** a mixed-version repository has evidence records but an existing hook reads `state.json` using the current line-oriented contract
- **THEN** existing top-level keys and formatting remain readable and hook behavior does not depend on understanding evidence records

### Requirement: Evidence writes preserve canonical state and privacy
Evidence writers MUST use an idempotent record identity, avoid partially valid records, and expose write failure. Failure to retain non-critical historical evidence MUST NOT modify, truncate, or otherwise corrupt `state.json`, onboarding content, or previously valid evidence. Evidence MUST use allowlisted compact fields and MUST NOT store secrets, credentials, full prompts, chain-of-thought, conversational transcripts, environment dumps, or high-volume raw runtime logs.

#### Scenario: Retry after interrupted evidence write
- **WHEN** an evidence write is retried after interruption
- **THEN** the same logical event produces one valid record and preserves all previously valid records

#### Scenario: Non-critical runtime history write fails
- **WHEN** runtime verification has already produced a result but its optional lifecycle history record cannot be persisted
- **THEN** the runtime result is reported as evidence-recording degraded while canonical onboarding state and prior evidence remain unchanged

#### Scenario: Source output contains a sensitive value
- **WHEN** a validator or runtime output includes a credential, prompt content, environment value, or raw log material outside the evidence allowlist
- **THEN** that value is omitted rather than copied into the durable evidence record

### Requirement: Compatibility migration is additive and reversible
The system SHALL introduce evidence storage without requiring destructive state migration. Existing repositories with only `state.json` MUST continue to work, existing compression receipts MUST be preserved, and new readers MUST tolerate absent evidence. Any later removal of legacy receipt fields requires a separately authorized contraction after all maintained consumers have migrated.

#### Scenario: Repository has no evidence store
- **WHEN** an existing repository first runs an evidence-aware lifecycle workflow
- **THEN** the workflow creates evidence additively while preserving all existing operational state and receipts

#### Scenario: Evidence-aware change is rolled back
- **WHEN** evidence-aware writers or readers are removed during rollback
- **THEN** existing hooks and lifecycle operations can continue from preserved `state.json` without parsing or deleting historical evidence

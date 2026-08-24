# self-hosted-onboarding Specification

## Purpose

Make the AIBoarding repository a real consumer of its supported onboarding lifecycle and a durable end-to-end acceptance case for that lifecycle.

## Requirements

### Requirement: Repository exposes managed onboarding guidance
The repository SHALL maintain a root `AGENTS.md` as canonical cross-agent guidance, a runtime-specific `CLAUDE.md` adapter that imports but does not duplicate that guidance, and `.aiboarding/` operational state outside always-loaded instruction content. Canonical guidance MUST cover project purpose, stack, commands, architecture, domain concepts, guardrails, failure modes, completion verification, and escalation conditions, and MUST remain below the applicable Codex instruction budget.

#### Scenario: Fresh supported agent enters repository
- **WHEN** a supported coding agent starts a fresh session in the repository
- **THEN** it can discover all required project guidance from the managed onboarding artifacts without reading operational sync state

#### Scenario: Runtime adapter loads canonical guidance
- **WHEN** Claude Code loads the root runtime adapter
- **THEN** the adapter imports `AGENTS.md` and contains no duplicate canonical sections

### Requirement: Public lifecycle setup is idempotent
The repository SHALL use the same create and setup lifecycle offered to user repositories, with no self-host-only installer or schema variant. Repeated setup MUST preserve user-owned content and MUST NOT duplicate managed files, hook entries, marker blocks, or state fields.

#### Scenario: Setup runs twice
- **WHEN** lifecycle setup is applied twice to the same repository state
- **THEN** the second run produces one copy of each managed artifact, marker block, hook entry, and state field

### Requirement: Self-hosted onboarding passes maintenance checks
The repository's known-good onboarding state SHALL produce no unresolved `FAIL` finding from the public audit workflow. Compression of its canonical guidance MUST preserve protected commands, paths, identifiers, URLs, code, markers, and table structure and MUST keep the result within the configured size budget.

#### Scenario: Audit known-good repository
- **WHEN** the onboarding audit runs against the maintained repository state
- **THEN** it reports no unresolved `FAIL` findings

#### Scenario: Compress canonical guidance
- **WHEN** the public compression workflow processes the repository's canonical guidance
- **THEN** preservation and size-budget checks pass without changing protected content

### Requirement: Drift tracking detects relevant changes without loops
The repository SHALL evaluate committed changes since the operational sync pointer. Changes affecting stack, commands, architecture, domain concepts, guardrails, verification, or failure modes MUST be eligible for onboarding review. A range containing no onboarding-relevant changes MUST advance only operational state and MUST leave `AGENTS.md` and `CLAUDE.md` byte-identical. Changes limited to managed onboarding documents or operational state MUST NOT trigger another drift notification.

#### Scenario: Irrelevant change is triaged
- **WHEN** update triage finds no onboarding-relevant change since the sync pointer
- **THEN** it advances the pointer without modifying either onboarding instruction document

#### Scenario: Relevant product change is triaged
- **WHEN** a committed change materially affects an onboarding scope
- **THEN** update triage identifies the affected canonical section for review

#### Scenario: Onboarding bookkeeping is committed
- **WHEN** the unsynced range contains only managed onboarding documents or `.aiboarding/` state
- **THEN** drift evaluation stays silent and does not create a self-referential loop

### Requirement: Repository remains a lifecycle acceptance case
Repository verification SHALL cover managed-layout integrity, setup idempotency, no-op update behavior, relevant-drift behavior, audit results, compression preservation, and the existing Bash suite. Existing plugin packaging, skills, templates, fixtures, and user-facing lifecycle behavior MUST remain compatible.

#### Scenario: Maintainer runs full verification
- **WHEN** the documented self-host acceptance procedure and existing Bash suite run in a known-good checkout
- **THEN** every lifecycle acceptance check passes without replacing or weakening fixture-based tests

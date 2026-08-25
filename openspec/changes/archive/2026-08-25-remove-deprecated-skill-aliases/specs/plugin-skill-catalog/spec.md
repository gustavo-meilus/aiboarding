## Purpose

Defines the supported skills that AIBoarding distributions expose and the names users and lifecycle guidance can rely on.

## ADDED Requirements

### Requirement: Distribution exposes only supported skills
The AIBoarding skill catalog SHALL expose `create-agent-onboarding`, `update-agent-onboarding`, `migrate-aiboarding`, `compress-onboarding`, and `audit-agent-onboarding`. It MUST NOT expose the retired `create-aiboarding` or `update-aiboarding` aliases.

#### Scenario: Plugin skill discovery
- **WHEN** an agent discovers skills from an installed AIBoarding plugin
- **THEN** the catalog contains the five supported skills and neither retired alias

#### Scenario: Skills copied from the repository
- **WHEN** a user copies the repository's `skills` directory into an agent skill-discovery path
- **THEN** the copied catalog contains no `create-aiboarding` or `update-aiboarding` skill

### Requirement: Active guidance uses supported skill names
Current user guidance and generated lifecycle nudges SHALL direct users only to supported AIBoarding skill names. Historical release records MAY retain retired names when documenting behavior that existed in those releases.

#### Scenario: Legacy layout drift nudge
- **WHEN** drift is detected for a repository that still uses the legacy `AIBOARDING.md` layout
- **THEN** the nudge directs the user to the supported migration workflow and does not name a retired alias

#### Scenario: Current documentation
- **WHEN** a user reads current setup, usage, verification, or repository-layout guidance
- **THEN** retired aliases are not presented as available skills

### Requirement: Retired invocations have an explicit migration path
The removal SHALL document that callers of `create-aiboarding` migrate to `create-agent-onboarding` and callers of `update-aiboarding` migrate to `update-agent-onboarding`.

#### Scenario: User updates existing automation
- **WHEN** a user reviews the breaking-change guidance before upgrading
- **THEN** each retired command name is mapped to its canonical replacement

### Requirement: Self-host audit checks operational onboarding
The self-host audit SHALL validate command paths independently from their arguments and MUST NOT treat test-fixture onboarding files as operational guidance.

#### Scenario: Auditing this repository
- **WHEN** the evidence-aware audit runs at the repository root
- **THEN** it reports genuine operational onboarding failures without failures caused by command arguments or files under `tests/fixtures/`

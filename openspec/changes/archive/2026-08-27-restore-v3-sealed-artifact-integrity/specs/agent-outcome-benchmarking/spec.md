## ADDED Requirements

### Requirement: Sealed benchmark artifacts preserve experiment integrity
Every supported benchmark profile that declares sealed artifact SHA-256 values SHALL validate the selected task, condition, and grader artifacts against those declarations before accepting the experiment. Validation MUST fail deterministically when any declared value does not match the selected artifact, MUST NOT repair or rewrite the declaration, and MUST complete before any live agent execution can start. Profiles that do not declare this sealed-artifact contract SHALL retain their existing validation behavior.

#### Scenario: Valid sealed profile is accepted
- **WHEN** a supported profile declares task, condition, and grader SHA-256 values that match the selected artifacts
- **THEN** sealed-artifact validation succeeds without changing the manifest or experiment identity

#### Scenario: Declared task hash is corrupted
- **WHEN** only the declared task SHA-256 differs from the selected task artifact
- **THEN** validation fails deterministically before any live agent execution

#### Scenario: Declared condition hash is corrupted
- **WHEN** only the declared condition SHA-256 differs from the selected condition artifact
- **THEN** validation fails deterministically before any live agent execution

#### Scenario: Declared grader hash is corrupted
- **WHEN** only the declared grader SHA-256 differs from the selected grader artifact
- **THEN** validation fails deterministically before any live agent execution

#### Scenario: Multiple declared hashes are corrupted
- **WHEN** more than one declared sealed artifact SHA-256 differs from its selected artifact
- **THEN** validation fails deterministically before any live agent execution

#### Scenario: Sealed artifact content changes
- **WHEN** selected task, condition, or grader content changes without updating its declared SHA-256
- **THEN** validation fails deterministically before any live agent execution

#### Scenario: Supported sealed profile versions are validated consistently
- **WHEN** any supported profile version that declares sealed artifact hashes contains a corrupted task, condition, or grader declaration
- **THEN** the profile is rejected by the same sealed-artifact integrity rule

#### Scenario: Legacy profile has no sealed-hash contract
- **WHEN** a supported legacy profile does not declare sealed task, condition, and grader hashes
- **THEN** its existing validation behavior remains unchanged

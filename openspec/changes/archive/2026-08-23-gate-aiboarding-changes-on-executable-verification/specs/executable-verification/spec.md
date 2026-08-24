## Purpose

Defines machine-enforced evidence required before repository changes can merge and exact commits can be treated as releaseable.

## ADDED Requirements

### Requirement: Proposed changes receive executable verification
The repository SHALL run its existing automated Bash harness as a required CI check for every pull request targeting the release branch and for every push to that branch. CI SHALL treat any non-zero harness exit as a failed check.

#### Scenario: Harness regression rejects a pull request
- **WHEN** a pull request causes any test executed by the existing Bash harness to return non-zero
- **THEN** executable verification completes with a failed CI result and the pull request cannot satisfy the repository gate

#### Scenario: Harness remains directly runnable
- **WHEN** a developer invokes the existing harness locally
- **THEN** it runs without requiring the GitHub Actions environment

### Requirement: Deterministic plugin contracts are gated
The repository SHALL execute deterministic plugin and manifest contract validation in CI without duplicating its assertions in workflow configuration. Any contract violation SHALL fail the CI check.

#### Scenario: Invalid manifest rejects a pull request
- **WHEN** a pull request violates a deterministic plugin or manifest contract covered by repository validation
- **THEN** CI reports a failed check rather than a warning

### Requirement: Verification covers material host differences
The repository SHALL run executable verification on each supported host environment whose platform behavior materially differs. Identical behavior SHALL NOT require redundant platform jobs.

#### Scenario: Platform-dependent behavior changes
- **WHEN** a supported host has materially different shell, path, or process behavior exercised by the repository
- **THEN** CI runs the relevant verification on that host and includes its result in the required gate

### Requirement: Security scanning remains enforced
The existing security scan SHALL continue to run for pull requests and release-branch pushes, and findings at its configured failure threshold SHALL remain failed checks.

#### Scenario: Security scan executes beside engineering verification
- **WHEN** a pull request targets the release branch
- **THEN** both security scanning and executable engineering verification execute independently

### Requirement: CI evidence identifies the verified commit
Every successful executable verification run SHALL expose the exact commit SHA it verified in machine-recorded run metadata and human-readable job output.

#### Scenario: Successful run records identity
- **WHEN** executable verification succeeds
- **THEN** its recorded head SHA and job output identify the same commit that supplied the tested checkout

### Requirement: Release verification uses exact-commit CI evidence
A release target SHALL be considered verified only when externally recorded required CI runs for that exact commit have completed successfully. Local command output, maintainer prose, or agent claims SHALL NOT substitute for that evidence.

#### Scenario: Verified release target is accepted
- **WHEN** every required workflow has a completed successful run whose recorded head SHA equals the release target SHA
- **THEN** release preparation reports the target as verified

#### Scenario: Different commit is not accepted
- **WHEN** required workflows are green only for a commit other than the release target SHA
- **THEN** release preparation fails verification

#### Scenario: Missing or failing run is not accepted
- **WHEN** any required workflow for the release target is missing, incomplete, cancelled, or unsuccessful
- **THEN** release preparation exits unsuccessfully and does not convert the condition into a warning

## Purpose

Defines reproducible acceptance evidence for onboarding and lifecycle behavior exercised against real supported agent runtimes without trusting runtime self-reporting.

For this change's live acceptance, the selected runtime is Codex CLI. Claude Code
coverage remains deterministic or manual until its authentication and external
lifecycle oracle are available.

## ADDED Requirements

### Requirement: Live protocols run in isolated repositories
The live-runtime verifier SHALL create a fresh disposable Git repository for each protocol case and SHALL NOT install generated onboarding, hooks, configuration, commits, or runtime artifacts into the maintainer's working repository. Each case MUST start from declared fixture state and MUST clean up or retain its scratch repository according to an explicit evidence-retention option.

#### Scenario: Protocol mutates its fixture
- **WHEN** a live protocol creates onboarding files, settings, commits, logs, or runtime state
- **THEN** every mutation occurs inside its disposable repository or dedicated evidence directory and the maintainer's repository remains unchanged

### Requirement: Native onboarding loading uses paired external controls
For every supported runtime selected for verification, the verifier SHALL run at least one positive case with a generated high-entropy onboarding canary and one negative case where the expected onboarding source is absent or deliberately broken. An external harness MUST determine the verdict from exact canary presence or absence, process status, and structured runtime evidence; a runtime statement that loading succeeded MUST NOT constitute proof.

#### Scenario: Fresh session loads expected onboarding
- **WHEN** the harness starts a fresh supported runtime in a positive scratch repository without placing the canary in the user prompt
- **THEN** captured evidence contains the exact generated canary through the runtime's native onboarding path and satisfies all protocol guards against alternate file or tool reads

#### Scenario: Absent or broken onboarding is distinguishable
- **WHEN** the harness starts the same runtime and protocol with the native onboarding source absent or deliberately broken
- **THEN** captured evidence does not contain the positive canary and the harness records the expected negative result rather than reusing or inferring successful loading

#### Scenario: Runtime uses an unapproved observation path
- **WHEN** structured events show that the runtime obtained or attempted to obtain the canary through a tool call, prompt content, retained session, or another path disallowed by the protocol
- **THEN** the harness fails the case even if final runtime output contains the canary

### Requirement: Applicable lifecycle delivery is externally observable
The verifier SHALL exercise each lifecycle behavior declared automatable for a supported runtime with both a qualifying event and a non-qualifying or absent condition. It MUST decide delivery and silence from runtime events, hook-owned logs or files, process execution records, or equivalent external evidence rather than from the agent's interpretation.

#### Scenario: Qualifying lifecycle event delivers context
- **WHEN** a protocol causes a declared qualifying session, subagent, instruction-loading, or Git-related lifecycle event
- **THEN** external evidence identifies the expected hook or context delivery for that event and attributes it to the current runtime session

#### Scenario: Non-qualifying event remains silent
- **WHEN** a protocol causes the paired non-qualifying event, including non-Git activity for drift filtering where applicable
- **THEN** external evidence contains no prohibited hook execution, context delivery, nudge, or filesystem side effect during the bounded observation window

#### Scenario: Hook process runs but behavior stays silent
- **WHEN** a runtime version cannot pre-filter a non-qualifying event but the hook's own input gate suppresses output
- **THEN** the result is explicitly degraded with process-spawn evidence and MUST NOT be reported as a full pass for filtering

### Requirement: Evidence is machine-readable and attributable
Every protocol result SHALL record the runtime name and version, protocol and case identifiers, start and end times, command exit status, repository commit and dirty-state snapshot, fixture identity, runtime arguments, verdict, and paths or hashes for captured raw output, events, logs, and filesystem evidence. Evidence containing credentials or runtime authentication material MUST be redacted or excluded before retention or upload.

#### Scenario: Protocol completes
- **WHEN** a live case reaches any terminal verdict
- **THEN** its machine-readable record contains enough identity and evidence references for an independent process to reproduce the verdict without consulting agent prose

#### Scenario: Evidence cannot be parsed or attributed
- **WHEN** required runtime output is malformed, truncated, missing, or cannot be tied to the tested session and repository state
- **THEN** the case fails or is explicitly degraded according to its declared capability policy and never passes

### Requirement: Compatibility failures cannot become false passes
Each runtime adapter SHALL probe required executable, authentication, version, non-interactive mode, and structured-evidence capabilities before running protocols. A requested required capability that is missing or incompatible MUST fail; a capability declared optional for that runtime version MAY produce a degraded result with a machine-readable reason. Degraded results MUST be distinct from passes and MUST affect the suite outcome according to the selected strictness policy.

#### Scenario: Supported runtime satisfies capability probe
- **WHEN** the installed runtime exposes the required command mode and evidence surface
- **THEN** the harness records the discovered capabilities and runs the applicable positive and negative protocols

#### Scenario: Runtime version is incompatible
- **WHEN** a selected runtime lacks a required event, output mode, authentication, or hook behavior
- **THEN** the harness records the runtime version and decisive incompatibility evidence and returns failed or explicitly degraded status rather than success

#### Scenario: Runtime command fails
- **WHEN** a runtime exits non-zero, times out, or emits a terminal error event
- **THEN** the affected case does not pass even if partial output resembles expected evidence

### Requirement: Live verification remains separate and cost-controlled
Live-runtime verification SHALL remain separate from the deterministic `tests/run.sh` contract suite. Local execution MUST be explicit, and CI execution MUST use credential-aware manual or scheduled cadence with bounded runtime, concurrency, and per-run cost where the runtime supports it. Missing CI credentials MUST prevent invocation or yield a visible unavailable result, never a synthetic pass.

#### Scenario: Developer runs deterministic tests
- **WHEN** a developer invokes the existing deterministic test harness
- **THEN** it completes without launching a paid or authenticated live runtime

#### Scenario: Live workflow is invoked with credentials
- **WHEN** an authorized manual or scheduled workflow selects supported runtimes and valid credentials are available
- **THEN** it runs the isolated live suite under declared time and cost bounds and retains the machine-readable summary and sanitized evidence artifacts

### Requirement: Manual verification remains available for unautomated behavior
The verification runbook SHALL retain protocols that cannot yet be automated reliably and SHALL label each protocol as automated, partially automated, or manual with the reason and authoritative evidence source. Automated live tests MUST complement, not replace, deterministic contract tests.

#### Scenario: Protocol lacks reliable automation
- **WHEN** a runtime behavior cannot be externally triggered or observed with stable machine-readable evidence
- **THEN** the runbook preserves its manual procedure and the automated suite does not claim coverage for it

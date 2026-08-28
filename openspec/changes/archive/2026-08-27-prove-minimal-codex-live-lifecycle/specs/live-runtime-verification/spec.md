## ADDED Requirements

### Requirement: Native onboarding loading uses protocol-appropriate external controls
Each live onboarding protocol SHALL declare the minimum external controls needed to distinguish native loading from prompt echo, retained session state, or tool-assisted file access. The maintained Codex lifecycle canary SHALL use one fresh positive session because its purpose is limited to composing native `AGENTS.md` loading with the `UserPromptSubmit` pre-turn runtime boundary; deterministic tests SHALL remain the authoritative oracle for AIBoarding lifecycle semantics and broader live controls SHALL remain separately invocable or manual.

#### Scenario: Fresh Codex session loads expected onboarding
- **WHEN** the maintained Codex canary starts one fresh positive session in a disposable repository without placing its generated onboarding canary in the user prompt
- **THEN** captured structured evidence contains the exact canary through the native project instruction path and no second live case starts automatically

#### Scenario: Native onboarding evidence is absent
- **WHEN** the positive Codex session produces attributable `UserPromptSubmit` collector evidence but its structured runtime evidence does not contain the exact generated onboarding canary
- **THEN** the harness fails the case rather than inferring native onboarding loading from hook execution

#### Scenario: Runtime uses an unapproved observation path
- **WHEN** structured evidence shows that the runtime obtained or attempted to obtain the canary through a tool call, prompt content, retained session, web access, or another path disallowed by the protocol
- **THEN** the harness fails the case even if final runtime output contains the canary

#### Scenario: Broader runtime behavior needs verification
- **WHEN** onboarding absence, subagent behavior, drift filtering, host compatibility, or another lifecycle semantic must be checked
- **THEN** deterministic tests or an explicitly selected manual protocol provide that evidence without adding a model session to the maintained Codex canary

## MODIFIED Requirements

### Requirement: Applicable lifecycle delivery is externally observable
The maintained Codex canary SHALL externally observe the `UserPromptSubmit` pre-turn hook surface during the same isolated session used to prove native onboarding loading. Its verdict MUST depend on fresh hook-owned collector evidence rather than the model's interpretation. AIBoarding-specific `SessionStart` delivery, silence, subagent, drift, and host-launcher semantics SHALL remain independently covered by deterministic tests or explicitly documented manual protocols.

#### Scenario: Qualifying lifecycle event delivers context
- **WHEN** the positive Codex canary completes
- **THEN** a newly created, parseable collector record identifies `UserPromptSubmit` within that case's unique disposable execution, uses an explicit output argument rather than a non-core inherited environment variable, and is retained with the structured runtime evidence

#### Scenario: UserPromptSubmit evidence is absent or invalid
- **WHEN** the collector record is missing, malformed, stale, identifies another event, or cannot be attributed to the current isolated run
- **THEN** the live case fails even if native onboarding evidence is present

#### Scenario: Windows collector command survives Codex command transport
- **WHEN** the Codex live canary runs on Windows
- **THEN** its `commandWindows` hook value is a quote-free scratch-relative `.cmd` trampoline, and that trampoline keeps the quoted wrapper, collector script, and positional collector-output paths outside Codex's outer `cmd.exe /C` command wrapping

#### Scenario: Non-qualifying event remains silent
- **WHEN** SessionStart decisions, SubagentStart pointers, Git or non-Git drift filtering, or another lifecycle silence condition is verified
- **THEN** deterministic repository tests remain the authoritative oracle and the maintained live canary does not reproduce the non-qualifying condition with another model session

#### Scenario: Hook process runs but behavior stays silent
- **WHEN** an explicitly selected broader runtime protocol observes a hook process for a non-qualifying event whose own input gate suppresses output
- **THEN** that protocol records the runtime behavior according to its declared capability policy and does not reinterpret process spawn as lifecycle delivery

### Requirement: Compatibility failures cannot become false passes
Each runtime adapter SHALL probe required executable, authentication, version, non-interactive mode, and structured-evidence capabilities before running protocols. A requested required capability that is missing or incompatible MUST fail; a capability declared optional for that runtime version MAY produce a degraded result with a machine-readable reason. Degraded results MUST be distinct from passes and MUST affect the suite outcome according to the selected strictness policy.

#### Scenario: Supported runtime satisfies capability probe
- **WHEN** the installed runtime exposes the required command mode and evidence surface
- **THEN** the harness records the discovered capabilities and runs only the cases explicitly declared by the selected protocol

#### Scenario: Runtime version is incompatible
- **WHEN** a selected runtime lacks a required event, output mode, authentication, or hook behavior
- **THEN** the harness records the runtime version and decisive incompatibility evidence and returns failed or explicitly degraded status rather than success

#### Scenario: Runtime command fails
- **WHEN** a runtime exits non-zero, times out, or emits a terminal error event
- **THEN** the affected case does not pass even if partial output resembles expected evidence

### Requirement: Live verification remains separate and cost-controlled
Live-runtime verification SHALL remain separate from the deterministic `tests/run.sh` contract suite. Local execution MUST be explicit, and CI execution MUST use credential-aware manual or scheduled cadence with bounded runtime, concurrency, and per-run cost. The maintained lifecycle workflow MUST be Codex-only, MUST start no more than one model session in total, and MUST NOT start a Claude or other runtime model session on the same trigger. Its Codex invocation MUST perform no automatic retry and MUST use `gpt-5.6-luna` with low reasoning, a disposable Codex user layer limited to required authentication and the test collector, disabled web and unrelated optional capabilities, ephemeral structured output, and read-only sandboxing. Sanitized evidence MUST be retained for successful and unsuccessful terminal outcomes. Missing CI credentials MUST prevent invocation or yield a visible unavailable result, never a synthetic pass.

#### Scenario: Developer runs deterministic tests
- **WHEN** a developer invokes the existing deterministic test harness
- **THEN** it completes without launching a paid or authenticated live runtime

#### Scenario: Live workflow is invoked with credentials
- **WHEN** an authorized manual or scheduled workflow invokes the maintained Codex lifecycle protocol with valid credentials
- **THEN** it starts exactly one positive Codex model session with the declared controls, starts no Claude or other model session, performs no retry or follow-on matrix, and retains its machine-readable summary and sanitized evidence artifacts for any terminal verdict

#### Scenario: Complete runtime failure is inspectable
- **WHEN** the one Codex session returns a legitimate failure with complete attributable evidence
- **THEN** the workflow retains that evidence and reports the failure without silently retrying or replacing it

## REMOVED Requirements

### Requirement: Native onboarding loading uses paired external controls
**Reason**: Requiring a negative model session in every maintained live invocation duplicates deterministic evidence and does not answer the narrower Codex integration question more strongly than one positive session joined to external pre-turn hook evidence.

**Migration**: Use `Native onboarding loading uses protocol-appropriate external controls`; retain paired or absent-onboarding protocols as separately invoked historical/manual evidence when they are specifically needed.

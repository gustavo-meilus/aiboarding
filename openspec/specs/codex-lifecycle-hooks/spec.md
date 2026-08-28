# codex-lifecycle-hooks Specification

## Purpose

Provide Codex users with native, quiet, and verifiable onboarding lifecycle signals while preserving portable manual skill operation and shared decisions across supported runtimes.

## Requirements

### Requirement: Codex plugin installations expose only shipped lifecycle capabilities
The Codex plugin SHALL bundle every lifecycle hook it declares using Codex-supported plugin paths and event schemas. Its manifest MUST claim hook capability only when the referenced hook configuration and handlers are present and independently verifiable.

#### Scenario: Installed plugin contains lifecycle hooks
- **WHEN** a user installs and enables the AIBoarding Codex plugin
- **THEN** Codex can discover the bundled hook configuration without any Claude-specific settings or environment variables

#### Scenario: Manifest is checked against shipped files
- **WHEN** plugin validation examines a declared hook capability
- **THEN** every declared hook path, handler, and required runtime-neutral helper exists and passes deterministic packaging checks

### Requirement: Codex drift signals use shared classification semantics
After confirmed Git-related activity, the Codex drift hook SHALL evaluate `last_synced_commit..HEAD` through the same runtime-neutral drift classifier and state contract used by other supported runtimes. Runtime adapters MUST NOT add, remove, reorder, or reinterpret drift categories.

#### Scenario: Relevant repository delta produces a drift signal
- **WHEN** a confirmed Git command completes and the shared classifier routes the repository delta to onboarding review or revalidation
- **THEN** Codex receives a concise signal to run `update-agent-onboarding` with the shared decision evidence

#### Scenario: Irrelevant repository delta stays silent
- **WHEN** a confirmed Git command completes and the shared classifier proves the entire repository delta irrelevant
- **THEN** the Codex hook emits no onboarding nudge

#### Scenario: Repository is already synchronized
- **WHEN** `last_synced_commit` equals `HEAD`
- **THEN** the Codex hook emits no onboarding nudge

#### Scenario: Confirmed Git activity has uncertain state
- **WHEN** a confirmed Git command completes but the sync pointer or classified range is missing, malformed, unresolvable, or incomplete
- **THEN** the Codex hook emits a repair or revalidation signal instead of treating the range as irrelevant

#### Scenario: Non-Git activity does not nudge
- **WHEN** a Codex tool event does not identify confirmed Git-related activity
- **THEN** the drift adapter exits silently without invoking drift classification

#### Scenario: Equivalent runtime inputs produce equivalent decisions
- **WHEN** Claude and Codex adapters provide the same repository root, base commit, head commit, and configuration to the shared classifier
- **THEN** both adapters receive the same classification route and decisive evidence

### Requirement: Codex startup checks preserve native onboarding delivery
The Codex startup hook SHALL rely on Codex native `AGENTS.md` loading and MUST NOT emit canonical onboarding document content. It SHALL remain silent when the Codex-managed layout is valid and emit only an actionable repair or migration reminder when the layout is missing or legacy.

#### Scenario: Valid managed layout is silent
- **WHEN** Codex starts or resumes in a repository with a valid canonical AIBoarding layout
- **THEN** the startup hook emits no additional context

#### Scenario: Canonical onboarding is missing
- **WHEN** Codex starts in a repository without the canonical onboarding file
- **THEN** the startup hook emits a concise offer to run `create-agent-onboarding` without duplicating document content

#### Scenario: Legacy layout is detected
- **WHEN** Codex starts in a repository that has legacy `AIBOARDING.md` and no `AGENTS.md`
- **THEN** the startup hook emits a concise reminder to run `migrate-aiboarding`

### Requirement: Codex subagents receive minimal onboarding context
Where Codex exposes `SubagentStart`, the lifecycle hook SHALL add only a short pointer to the repository `AGENTS.md` and its binding sections. It MUST NOT inject the document body or duplicate content Codex can load from disk.

#### Scenario: Subagent starts in a managed repository
- **WHEN** Codex starts a subagent and repository `AGENTS.md` exists
- **THEN** the subagent receives a bounded pointer naming `AGENTS.md` and the binding guardrail, failure-mode, and verification sections

#### Scenario: Subagent starts without onboarding
- **WHEN** Codex starts a subagent and repository `AGENTS.md` does not exist
- **THEN** the subagent hook stays silent

### Requirement: Lifecycle hooks are optional enhancements
AIBoarding generation, update, compression, migration, and audit skills SHALL remain usable when Codex hooks are unavailable, disabled, untrusted, or unsupported. Runtime guidance SHALL identify explicit `update-agent-onboarding` execution as the manual drift-lifecycle fallback.

#### Scenario: Hooks feature is disabled
- **WHEN** Codex runs with lifecycle hooks disabled
- **THEN** AIBoarding skills continue to operate without Claude-specific configuration and document manual update invocation after meaningful commits

#### Scenario: Plugin hooks await trust review
- **WHEN** Codex skips newly installed or changed plugin hooks pending user trust
- **THEN** skill operation remains available and no basic onboarding action depends on hook execution

#### Scenario: Portable skills are copied without the plugin
- **WHEN** a compatible agent loads AIBoarding `SKILL.md` directories without plugin-bundled hooks
- **THEN** all skill workflows remain functional with manual lifecycle guidance

### Requirement: Existing runtime behavior remains compatible
Adding Codex lifecycle hooks SHALL preserve existing Claude Code lifecycle behavior, managed repository state readability, and cross-agent skill compatibility. Runtime-specific adapters MUST consume native event payloads and environment variables only at their boundary.

#### Scenario: Claude lifecycle remains functional
- **WHEN** existing Claude Code hook fixtures and live protocols run after Codex hook support is added
- **THEN** startup, drift, subagent, diagnostics, and loop-suppression behavior retain their prior outcomes

#### Scenario: Runtime-specific payloads remain isolated
- **WHEN** a Codex or Claude event payload changes adapter input handling
- **THEN** the runtime-neutral drift and layout decisions remain independent from runtime-specific environment variables and event field names

### Requirement: Native Codex behavior has deterministic and live proof
The project SHALL test runtime-neutral lifecycle decisions independently, exercise Codex event adapters with deterministic fixtures, and exercise supported host launchers with their native command interpreters. The maintained live Codex proof SHALL use one positive session to establish only native `AGENTS.md` loading and attributable `UserPromptSubmit` pre-turn hook delivery; broader `SessionStart`, plugin, trust, subagent, drift, and host semantics MUST remain deterministic or explicitly manual rather than expanding that canary.

#### Scenario: Adapter fixture validates event translation
- **WHEN** deterministic Codex hook fixtures cover supported, irrelevant, malformed, and JSON-escaped native Windows event payloads
- **THEN** tests prove the adapter invokes the correct shared decision or stays silent as specified

#### Scenario: Host launcher fixture validates command execution
- **WHEN** deterministic launcher checks run the configured Unix command through Bash and the configured Windows command through `cmd.exe`
- **THEN** both commands dispatch to the bundled lifecycle adapter without relying on the test runner's shell interpretation

#### Scenario: Live Codex protocol validates delivery
- **WHEN** a maintainer explicitly runs the maintained protocol in a current Codex runtime with a unique onboarding canary
- **THEN** one session's retained record identifies the runtime version and tested repository revision and proves both native `AGENTS.md` loading without an unauthorized tool path and attributable `UserPromptSubmit` collector execution

#### Scenario: Broader lifecycle proof remains available
- **WHEN** plugin discovery, trust, subagent delivery, drift classification, silence, or host-specific behavior requires verification
- **THEN** the project uses its authoritative deterministic checks or documented manual protocol without automatically starting another live canary case

### Requirement: Codex lifecycle launchers use shell-compatible plugin-root expansion
The bundled Codex hook configuration SHALL start its lifecycle adapter on Unix, macOS, WSL, and native Windows with a compatible Git Bash by resolving `PLUGIN_ROOT` with syntax understood by the command interpreter Codex selects. The Windows command MUST enter through the bundled portability wrapper, the wrapper MUST NOT select a WSL Bash shim for a native Windows plugin path, and every supported launcher MUST pass the event payload to the same bundled adapter. When native Windows has no compatible Bash, the optional hook MUST exit silently and manual lifecycle skills MUST remain usable.

#### Scenario: Unix or WSL launcher resolves the bundled adapter
- **WHEN** Codex runs in a Unix, macOS, or WSL environment, supplies `PLUGIN_ROOT`, and selects the default lifecycle command
- **THEN** the command resolves `hooks/codex-lifecycle` beneath the installed plugin root and passes the event payload to it

#### Scenario: Windows launcher resolves the bundled adapter
- **WHEN** native Windows Codex supplies `PLUGIN_ROOT`, selects `commandWindows`, and a compatible Git Bash is installed
- **THEN** `cmd.exe` resolves the bundled portability wrapper and the wrapper starts `hooks/codex-lifecycle` without invoking a WSL Bash shim or returning missing-path exit 127

#### Scenario: Windows drift event reaches lifecycle classification
- **WHEN** a native Windows `PostToolUse` event contains a JSON-escaped absolute Windows `cwd`, reports a matching Bash Git command, and the repository has a relevant delta newer than `last_synced_commit`
- **THEN** the adapter resolves the repository path and returns bounded `<aiboarding-drift></aiboarding-drift>` context using the existing shared classification semantics

#### Scenario: Windows non-Git command remains silent
- **WHEN** a native Windows `PostToolUse` event reports a matching Bash command that is not Git-related
- **THEN** the adapter starts and emits no onboarding context

#### Scenario: Native Windows lacks compatible Bash
- **WHEN** Codex selects `commandWindows` and no compatible Git Bash can be found
- **THEN** the optional hook exits without an error or onboarding context and the user can invoke lifecycle skills manually

#### Scenario: Independently sourced hooks remain unaffected
- **WHEN** the corrected AIBoarding lifecycle handler and another source's matching `PostToolUse` handler are both enabled
- **THEN** AIBoarding changes only its bundled handler configuration and does not disable or rewrite the independently sourced handler



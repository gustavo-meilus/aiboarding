## Purpose

Provide Codex users with native, quiet, and verifiable onboarding lifecycle signals while preserving portable manual skill operation and shared decisions across supported runtimes.

## ADDED Requirements

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
The project SHALL test runtime-neutral decisions independently, exercise Codex event adapters with deterministic fixtures, and maintain a live Codex protocol for plugin discovery, trust, startup context, subagent context, and drift-event delivery.

#### Scenario: Adapter fixture validates event translation
- **WHEN** deterministic Codex hook fixtures cover supported, irrelevant, and malformed event payloads
- **THEN** tests prove the adapter invokes the correct shared decision or stays silent as specified

#### Scenario: Live Codex protocol validates delivery
- **WHEN** a maintainer runs the documented protocol in a current Codex runtime with a unique onboarding canary
- **THEN** the record proves native `AGENTS.md` context, silent valid startup, bounded subagent context, hook trust state, and relevant-versus-irrelevant drift delivery

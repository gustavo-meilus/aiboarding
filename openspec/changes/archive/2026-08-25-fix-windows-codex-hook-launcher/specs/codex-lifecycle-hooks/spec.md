## ADDED Requirements

### Requirement: Codex lifecycle launchers use shell-compatible plugin-root expansion
The bundled Codex hook configuration SHALL start its lifecycle adapter on every supported host by resolving the `PLUGIN_ROOT` environment variable with syntax understood by the shell that executes the selected command. A Windows override that invokes Bash MUST use Bash-compatible environment expansion and MUST pass each supported event payload to the same bundled adapter as the default command.

#### Scenario: Windows launcher resolves the bundled adapter
- **WHEN** Codex selects a Windows lifecycle command, supplies `PLUGIN_ROOT`, and invokes the configured Bash command
- **THEN** the command resolves `hooks/codex-lifecycle` beneath the installed plugin root and starts without a missing-path exit 127

#### Scenario: Windows drift event reaches lifecycle classification
- **WHEN** a Windows `PostToolUse` event reports a matching Bash Git command and the repository has a relevant delta newer than `last_synced_commit`
- **THEN** the adapter receives the event through standard input and returns bounded `<aiboarding-drift></aiboarding-drift>` context using the existing shared classification semantics

#### Scenario: Windows non-Git command remains silent
- **WHEN** a Windows `PostToolUse` event reports a matching Bash command that is not Git-related
- **THEN** the adapter starts and emits no onboarding context

#### Scenario: Independently sourced hooks remain unaffected
- **WHEN** the corrected AIBoarding lifecycle handler and another source's matching `PostToolUse` handler are both enabled
- **THEN** AIBoarding changes only its bundled handler configuration and does not disable or rewrite the independently sourced handler

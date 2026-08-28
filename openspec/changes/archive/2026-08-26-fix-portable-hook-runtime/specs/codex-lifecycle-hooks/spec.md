## MODIFIED Requirements

### Requirement: Native Codex behavior has deterministic and live proof
The project SHALL test runtime-neutral decisions independently, exercise Codex event adapters with deterministic fixtures, exercise each supported host launcher with its native command interpreter, and maintain a live Codex protocol for plugin discovery, trust, startup context, subagent context, and drift-event delivery.

#### Scenario: Adapter fixture validates event translation
- **WHEN** deterministic Codex hook fixtures cover supported, irrelevant, malformed, and JSON-escaped native Windows event payloads
- **THEN** tests prove the adapter invokes the correct shared decision or stays silent as specified

#### Scenario: Host launcher fixture validates command execution
- **WHEN** deterministic launcher checks run the configured Unix command through Bash and the configured Windows command through `cmd.exe`
- **THEN** both commands dispatch to the bundled lifecycle adapter without relying on the test runner's shell interpretation

#### Scenario: Live Codex protocol validates delivery
- **WHEN** a maintainer runs the documented protocol in a current Codex runtime with a unique onboarding canary
- **THEN** the record identifies the host environment and proves native `AGENTS.md` context, silent valid startup, bounded subagent context, hook trust state, and relevant-versus-irrelevant drift delivery

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

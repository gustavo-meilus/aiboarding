## MODIFIED Requirements

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

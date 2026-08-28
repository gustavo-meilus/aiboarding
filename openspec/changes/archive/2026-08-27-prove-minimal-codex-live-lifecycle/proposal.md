## Why

The maintained Codex live-runtime workflow proves native `AGENTS.md` loading but does not exercise an event that `codex exec` emits. It also spends two model sessions on paired onboarding controls even though deterministic tests already provide the authoritative AIBoarding lifecycle semantics, leaving the actual pre-turn hook boundary unproven at unnecessary cost.

## What Changes

- Make the maintained live lifecycle workflow Codex-only: one positive, read-only, ephemeral session that jointly verifies native onboarding loading and attributable `UserPromptSubmit` collector execution, with no Claude or other model session on the same trigger.
- Pin the canary to `gpt-5.6-luna` with low reasoning, a disposable Codex user layer containing only required authentication and the test collector, an explicit collector output argument that does not depend on inherited hook environment, disabled web and unrelated optional capabilities, structured JSONL output, a bounded timeout, and no retry.
- Fail closed when onboarding, structured runtime output, or fresh attributable collector evidence is missing, malformed, timed out, or obtained through an unauthorized tool path.
- Retain sanitized, runtime-versioned, source-revision-attributed evidence for successful and unsuccessful runs.
- On Windows, transport the collector through a scratch-local, quote-free `.cmd` trampoline so Codex's `cmd.exe /C` command wrapping cannot corrupt embedded quoted paths.
- Keep AIBoarding-specific SessionStart, SubagentStart, drift, silence, and Windows launcher behavior authoritative in deterministic tests, with broader runtime protocols remaining manual where needed.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `live-runtime-verification`: Replace paired/broad maintained Codex live coverage with one positive composite boundary canary while preserving fail-closed attributable evidence and deterministic/live separation.
- `codex-lifecycle-hooks`: Define the live Codex proof as native onboarding plus the `UserPromptSubmit` pre-turn event surface, while retaining `SessionStart` lifecycle semantics and host behavior as deterministic or manual coverage.

## Impact

The existing live verifier, fake-runtime tests, Codex lifecycle and workflow contract tests, maintained live workflow, and verification runbook are affected. No plugin behavior, hook decision logic, evidence format, dependency, retry service, or ordinary deterministic test invocation changes; the maintained workflow performs one authenticated Codex session and retains its sanitized evidence for every verdict. Claude live verification remains separately explicit or manual and is not launched by that workflow.

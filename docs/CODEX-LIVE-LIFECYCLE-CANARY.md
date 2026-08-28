# Codex live lifecycle canary

This reference records the maintained live proof for Codex native onboarding and
`UserPromptSubmit` delivery. It is not a replacement for deterministic lifecycle
tests.

## Contract

One explicit Codex session must prove both of these in the same disposable Git
repository:

1. Native loading of a generated `AGENTS.md` canary.
2. A parseable collector record whose `hook_event_name` is `UserPromptSubmit`.

The collector, trust notices, or model output alone do not satisfy both halves.
The run uses Luna with low reasoning, disabled web search, JSONL, ephemeral mode,
a read-only sandbox, a disposable `CODEX_HOME`, and no retry or warmup.

Run it only with explicit authorization for one authenticated session:

```bash
python3 tests/live/verify_runtime.py \
  --live --strict --runtime codex --case positive \
  --collect-hooks --install-plugin --timeout 60 \
  --evidence-dir .aiboarding/live-evidence-<label>
```

The verifier retains a sanitized `summary.json`, case command, structured output,
stderr, parsed events, result, and collector JSONL. A missing, malformed,
wrong-event, or wrong-working-directory collector record fails closed.

## Definitive Windows fix

On Codex CLI 0.150.1, `commandWindows` hook commands are passed through
`cmd.exe /C` with an additional outer quote layer. A command such as:

```text
"<wrapper>" "<collector-script>" "<collector-output>"
```

contains embedded quotes and is malformed by that transport. The hook may be
discovered or trusted without executing the collector. This is a Codex Windows
command-transport defect, not a missing `UserPromptSubmit` dispatch, a trust-layer
failure, or an asynchronous collector race. See
[Codex PR #33926](https://github.com/openai/codex/pull/33926) and
[issue #38168](https://github.com/openai/codex/issues/38168).

The verifier fixes it only on Windows by writing this scratch-local trampoline:

```bat
@echo off
call "<repo>\templates\hooks\run-hook.cmd" "%~dp0collector.sh" "%~dp0collector.jsonl"
exit /b %ERRORLEVEL%
```

It configures the decoded `commandWindows` value as the quote-free relative token:

```text
.\aiboarding-user-prompt-submit.cmd
```

All paths that need quoting remain inside the batch file. The Unix hook command
is unchanged. The collector output is positional because Codex hook children use
a curated environment and do not preserve arbitrary `AIBOARDING_*` variables.

## Deterministic safeguards

`tests/live/test-live-runtime.sh` constructs the Windows hook configuration and
asserts that the trampoline exists, the command is quote-free and relative, the
Windows wrapper is used, and collector paths remain positional. The fake runtime
tests preserve fail-closed collector attribution; they do not claim to prove live
Codex lifecycle delivery.

Run the normal deterministic suite before a separately authorized live session:

```bash
bash tests/run.sh
```

## Retained successful evidence

The corrective Windows run passed on Codex CLI `0.150.1` with one Luna/low
session and no retry. Its native canary and `UserPromptSubmit` JSONL record are
retained under:

```text
.aiboarding/live-evidence-user-prompt-submit-trampoline-windows/
```

That evidence is specific to its recorded runtime version, repository revision,
and controls; it is not a general compatibility guarantee for other Codex
versions or lifecycle events.

## Context

See `proposal.md` for motivation and the two delta specifications for required behavior. The standard-library verifier already owns disposable repositories, native onboarding canaries, structured output, redaction, evidence hashing, and an opt-in Codex `UserPromptSubmit` collector. The maintained workflow currently selects both onboarding cases, omits hook collection, inherits runtime model/configuration defaults, and uploads detailed evidence only after failure.

The existing main specifications describe paired native-load controls and broad live lifecycle coverage. This change deliberately replaces that maintained Codex proof with a composition: deterministic AIBoarding semantics plus one live Codex session proving the two native runtime boundaries.

## Goals / Non-Goals

**Goals:**

- Reuse one verifier case and the existing inert collector as the complete live boundary proof.
- Make a pass depend on fresh native-load and `UserPromptSubmit` evidence from the same isolated execution.
- Bound model count, configuration, authority, cost, and retained evidence mechanically.

**Non-Goals:**

- Change production hook behavior, add a collector or evidence format, or infer broader lifecycle semantics from the canary.
- Add retry, scheduling, plugin-install, telemetry, or model-evaluation infrastructure.

## Decisions

### Compose existing deterministic and live evidence

The maintained workflow will contain only the Codex positive case and enable hook collection; it will not launch the current Claude job on the same manual or scheduled trigger. Deterministic lifecycle and workflow tests remain the oracle for AIBoarding decision logic, absence cases, subagents, drift, silence, and host launchers. Claude and other broader live protocols remain separately explicit or manual when their evidence is needed.

Alternative: retain the negative onboarding call or add a live lifecycle matrix. Rejected because neither is needed to prove native loading and pre-turn hook delivery and both increase cost and stochastic failure exposure.

### Reuse and validate the existing collector

The verifier will create a clean case evidence boundary and write the existing inert collector to `hooks.json` in its disposable `CODEX_HOME`, alongside only copied authentication. The generated scratch repository remains the session `cwd` and owns the onboarding canary. This uses the active user configuration layer: a fresh scratch repository has no trusted project configuration layer, and bypassing hook-definition review does not make that project layer active. The hook command passes the collector output path as a positional argument, because Codex hook commands receive a curated shell environment and cannot rely on arbitrary inherited variables. Accept evidence only when newly produced JSONL parses and identifies `UserPromptSubmit`. `codex exec` reliably emits this pre-turn event without requiring an extra agent, subagent, or tool call. Case-local paths, process lifetime, timestamps, repository/source identity, and evidence digests establish attribution to the unique run. A cross-stream session identifier is required only if the runtime reliably exposes the same identifier in both sources.

Alternative: introduce a new collector or evidence schema. Rejected because the current collector and case/result/summary artifacts already carry the required evidence when validated instead of merely checked for existence.

### Keep Windows hook transport quote-free

Codex 0.150.1 wraps a Windows hook command again before passing it to `cmd.exe /C`. The former `commandWindows` value embedded quoted wrapper, script, and collector paths, so that extra wrapping malformed the command even though hook dispatch occurred. On Windows the verifier SHALL write a scratch-local `aiboarding-user-prompt-submit.cmd` trampoline containing the quoted paths and configure `commandWindows` as only the relative, quote-free `.\\aiboarding-user-prompt-submit.cmd` token. The Unix command remains unchanged. This preserves the same `codex exec`, `UserPromptSubmit`, disposable user layer, and positional collector contract without retries or a new proof surface.

### Pin the smallest Codex command surface

The Codex case command will reuse the benchmark-established controls for explicit model and reasoning effort while pointing `CODEX_HOME` at the disposable, minimal user layer. It retains JSONL, ephemeral mode, read-only sandboxing, and trusted test-local hook execution. Web access and unrelated optional capabilities remain disabled. Fake-runtime tests will assert the composed command, isolated home, and one-session ceiling without authentication.

Alternative: rely on runtime defaults. Rejected because defaults are not attributable, stable evidence and can silently widen model cost or authority.

### Retain sanitized evidence for every verdict

Runtime streams and collector content will be sanitized before retention, parsed fail closed, and hashed in the existing result format. The workflow artifact step will run for success and failure. A legitimate complete failure remains the terminal result; there is no retry or follow-on case.

Alternative: retain detailed artifacts only on failure. Rejected because successful proof must remain independently inspectable and attributable.

## Risks / Trade-offs

- [A Codex event schema changes] → Preserve sanitized raw evidence and fail closed on missing, malformed, or wrong-event collector records.
- [A stale evidence directory creates a false pass] → Clear or uniquely scope case-local evidence before execution and require newly produced collector evidence.
- [The fresh scratch repository is untrusted] → Put the test-only collector in the disposable active user layer; keep the scratch repository only as the session working directory and verify collector attribution there.
- [Hook commands omit custom inherited variables] → Pass the collector output path directly to the inert collector instead of using environment transport.
- [One positive session does not prove lifecycle semantics] → Make no such claim; deterministic tests and retained manual protocols remain authoritative for those semantics.

## Migration Plan

Update the deterministic contracts and verifier first, then narrow the maintained workflow to its single Codex job and update documentation so Claude remains separately explicit or manual. Run all focused and full deterministic checks before one explicit live canary. The prior canary is retained as an invalid configuration-layer diagnostic; its corrective result establishes that the hook observer must not use inherited environment transport. After the collector-interface fix, a new live canary requires separate user authorization. If it fails, retain its evidence and keep the prior manual protocols available; do not retry automatically or broaden the run.

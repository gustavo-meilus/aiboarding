## Context

See `proposal.md` for motivation and `specs/live-runtime-verification/spec.md` for required behavior. The current repository has deterministic Bash tests for hook scripts and a manual `docs/VERIFICATION.md` for runtime loading, hook delivery, marketplace installation, compaction, and skill-reasoning behavior. Current local probes found Claude Code 2.1.237 with `--print`, `stream-json`, `--include-hook-events`, `--debug-file`, tool restriction, and cost limits; Codex CLI 0.149.0 provides `codex exec --json`, `--ephemeral`, explicit sandboxing, isolated config switches, and plugin management.

### Scope decision: Codex-only live acceptance

The final live acceptance target is Codex CLI. Claude Code's adapter and
deterministic coverage remain in the repository, but its expired authentication
and lack of attributable live evidence make it partial/manual for this change.
Codex `exec --json --ephemeral` supplies paired native-load results. Its JSONL
does not expose plugin `additionalContext`, so a scratch collector running
beside the trusted plugin is the lifecycle oracle for `SessionStart`,
`SubagentStart`, and `PostToolUse`. Collector records prove event delivery and
attribution; production context that remains invisible is recorded as partial,
never inferred from model prose.

Official Codex documentation confirms that `codex exec --json` emits machine-readable JSONL, hooks are enabled by default, project and plugin hooks require trust, `--dangerously-bypass-hook-trust` is intended only for automation that independently vets hook sources, and current lifecycle events include `SessionStart`, `SubagentStart`, and `PostToolUse` ([non-interactive mode](https://learn.chatgpt.com/docs/non-interactive-mode), [hooks](https://learn.chatgpt.com/docs/hooks)). The pending `add-native-codex-lifecycle-hooks` change owns Codex hook packaging and behavior; this change verifies it and must not implement a second hook path. The pending `gate-aiboarding-changes-on-executable-verification` change owns fast required CI; live verification stays a separate cost-bearing workflow.

## Goals / Non-Goals

**Goals:**

- Provide one cross-platform external harness with runtime-specific launch and evidence parsing.
- Prove native loading with paired controls that cannot pass by echoing a prompt token or reading the onboarding file through a tool.
- Observe lifecycle delivery and silence without modifying the maintainer's repository or trusting model-written verdicts.
- Preserve raw, attributable evidence while excluding credentials and user runtime state.
- Make runtime capability drift visible without forcing paid tests into normal development commands.

**Non-Goals:**

- Reimplement runtime hooks, hook classifiers, plugin packaging validation, or deterministic fixtures.
- Treat stochastic skill reasoning, forced compaction, or public marketplace propagation as automated until a stable external trigger and oracle exist.
- Support every runtime that can read `AGENTS.md`; initial adapters cover Codex and Claude Code only.
- Build a general agent-evaluation framework or add a package dependency.

## Decisions

### Use one Python standard-library harness

Add one Python 3 command under `tests/live/` that owns subprocess timeouts, temporary repositories, JSON/JSONL parsing, hashing, redaction, evidence summaries, and exit status. Runtime adapters remain small data-and-command modules inside that command. Add a deterministic shell test to `tests/run.sh` discovery using fake runtime executables and fixture event streams; it exercises positive, negative, malformed, timeout, and degraded adjudication without credentials or model calls.

Python's standard library is available on GitHub-hosted Ubuntu and Windows runners and avoids requiring `jq`, duplicating PowerShell and Bash parsers, or adding a package manager. The live command probes Python and runtime prerequisites before creating a case.

Alternative considered: extend `tests/run.sh` with Bash-only live tests. Rejected because robust cross-platform process control and JSONL validation would require more code or a new `jq` dependency, and normal deterministic test discovery must never launch live runtimes.

Alternative considered: use Claude plugin evals as the common harness. Rejected because they do not run Codex and their model or LLM graders would make the agent system part of the authority.

### Materialize every case in a fresh repository

For each case, copy only required onboarding, hook, plugin, and fixture files from the source tree into a new temporary Git repository, initialize known commits, and use separate positive and negative directories. Record the source `HEAD`, dirty state, and hashes of copied inputs. Evidence goes to a caller-selected directory outside each case or to a temporary evidence directory retained only on failure.

Runtime flags disable session persistence where available. The Claude adapter restricts setting sources and supplies scratch project settings. The Codex adapter uses ephemeral execution and ignores unrelated user configuration where the protocol does not require plugin state. Protocols that exercise installation require a dedicated runtime home or protected CI runner; they never add marketplaces or plugins to the maintainer's normal runtime configuration.

Alternative considered: use a Git worktree. Rejected because runtime sessions, settings, hooks, and generated commits would still share repository metadata and could affect maintainer state.

### Adjudicate canaries with paired fresh sessions and tool guards

Generate a different high-entropy token for each positive case and write it only into the native onboarding path: `AGENTS.md` for Codex, and `AGENTS.md` imported by the root `CLAUDE.md` for Claude Code. The user prompt asks for the loaded onboarding token but never includes it. A new non-persistent session runs with tools disabled on Claude; the Codex JSONL stream is rejected if it contains command, file, MCP, web, or other tool activity before returning the token. Final output must contain the exact token.

The negative arm uses a separate fresh repository and session with the relevant file absent or the Claude import broken. It must complete successfully without the positive token. The harness, not the model, checks exact output, event types, process status, session freshness, and forbidden tool activity. A free-form claim such as "onboarding loaded" has no bearing on the verdict.

Alternative considered: ask the agent whether it loaded onboarding. Rejected because that tests self-reporting rather than delivery.

### Combine runtime streams with independent hook collectors

Each lifecycle case captures runtime stdout/stderr and structured events. Scratch project settings add a test-only collector hook beside the copied production hook configuration; the collector writes its stdin event and timestamp to a case evidence file, then remains behaviorally inert. Production handlers remain byte-identical to the source under test. Positive delivery requires both the expected runtime event or collector record and the expected production output or filesystem effect. Silence cases require a bounded process exit, no prohibited production output/effect, and collector evidence showing what qualifying or non-qualifying event actually occurred.

Initial protocol coverage is:

| Protocol | Claude Code evidence | Codex evidence |
| --- | --- | --- |
| Native load positive/negative | `stream-json`, exact canary, tools disabled | `codex exec --json`, exact canary, no tool events |
| Session fallback and silence | `SessionStart` hook events plus repair context | Native Codex hook collector plus repair context after `add-native-codex-lifecycle-hooks` |
| Subagent pointer and absent-file silence | `SubagentStart` collector and hook context | Native Codex collector and hook context after `add-native-codex-lifecycle-hooks` |
| Drift qualifying and non-qualifying commands | `PostToolUse` stream/collector plus nudge or silence | Native Codex collector plus shared classifier output or silence after `add-native-codex-lifecycle-hooks` |
| Instruction-load diagnostics | `InstructionsLoaded` event and debug log on/off pair | Not applicable; Codex exposes no equivalent maintained diagnostic contract |

If the Codex lifecycle change is not present, native loading remains runnable but Codex lifecycle cases report an explicit unavailable/degraded capability; they cannot pass. Claude `/compact` survival, public marketplace propagation, and skill-reasoning cases remain manual until deterministic external triggers and oracles exist. Local strict plugin validation remains deterministic; isolated marketplace install can be added to the live profile only where a dedicated runtime home is available.

Alternative considered: instrument production hooks with a test logging environment variable. Rejected because scratch collector hooks provide runtime delivery evidence without adding test branches to shipped behavior.

### Use a small fixed evidence and verdict contract

Each case directory contains `case.json`, raw stdout/stderr, parsed runtime events, collector events, relevant filesystem snapshots or hashes, and `result.json`. The suite writes `summary.json`. Records include source repository state, runtime path and version, sanitized arguments, timestamps, fixture hashes, exit status, capability probes, verdict, and decisive evidence references. Environment dumps, prompts containing secrets, runtime auth files, and runtime homes are never retained.

Verdicts are `pass`, `fail`, or `degraded`. Exit code 0 means all requested cases passed, 1 means any case failed, and 2 means no failure occurred but at least one requested case degraded. `--strict` maps degraded suite results to exit 1 for scheduled verification. Unknown event shapes, missing evidence, timeouts, non-zero runtime exits, forbidden tool events, and required capability gaps fail closed.

Alternative considered: treat unavailable credentials or events as skipped success. Rejected because absence of evidence must remain visible and cannot satisfy the runtime contract.

### Run live CI only on protected cadence

Add a separate workflow with `workflow_dispatch` and a low-frequency schedule on the default branch. It does not run for pull requests, pushes, or `tests/run.sh`. Use runtime-specific jobs so one unavailable provider cannot hide the other's result, concurrency limits to prevent overlapping paid runs, command timeouts, and native cost ceilings where supported. Upload sanitized evidence and the suite summary even on failure.

Credentials are exposed only to the exact runtime invocation on a trusted default-branch checkout or dedicated self-hosted runner. Codex CI follows official guidance by preferring workload identity or the supported Codex action where it can preserve the CLI/hook behavior under test; otherwise a protected runner supplies invocation-scoped credentials. Claude uses equivalent protected provider credentials. If safe credential isolation cannot be established for a runtime, keep its scheduled job disabled and retain explicit local/manual execution rather than weakening secret boundaries.

Alternative considered: make live runs required on every pull request. Rejected because forked code, secrets, runtime cost, rate limits, and provider availability make that unsafe and noisy; deterministic CI remains the required merge gate.

### Keep the runbook as the coverage map

Rewrite `docs/VERIFICATION.md` into a matrix that points automated cases to their harness identifiers and authoritative evidence, retains manual steps verbatim where still needed, and labels partial automation. Documentation must not claim a protocol ran unless a retained result identifies its runtime version and source commit.

Alternative considered: delete automated sections from the runbook. Rejected because maintainers still need one inventory of runtime assumptions, coverage status, and manual fallback.

## Risks / Trade-offs

- [Model output remains probabilistic] → Use exact high-entropy tokens, minimal prompts, fresh paired sessions, zero-tool guards, bounded retries only for declared transient provider errors, and never reinterpret semantic prose.
- [Runtime JSON/event schemas change] → Probe versions and required fields first; preserve raw evidence; fail or degrade on unknown shapes instead of silently ignoring them.
- [Collector hook changes event timing] → Keep it append-only, local, and minimal; run it beside rather than around production hooks, and record timeouts separately.
- [A runtime obeys the canary instruction inconsistently] → Treat mismatch as failure; do not add an LLM grader or broaden matching.
- [Scheduled secrets could reach repository-controlled code] → Run only trusted default-branch revisions in protected environments and scope credentials to the runtime process; disable scheduled execution where this cannot be guaranteed.
- [Concurrent OpenSpec changes overlap hooks and CI] → Reuse shipped Codex hooks and the shared drift classifier, keep the live workflow separate from deterministic gates, and reconcile paths during apply rather than copying pending implementations.
- [Hosted runner images or providers vary] → Record executable paths and versions, pin setup actions where practical, and make capability loss explicit in the result.

## Migration Plan

1. Add the deterministic fake-runtime tests and minimal harness contract without changing existing test discovery semantics.
2. Implement isolated native-load positive and negative cases for Claude Code and Codex, then run them locally against recorded runtime versions.
3. Add Claude lifecycle collectors and cases; add Codex lifecycle cases only against the shipped native hook adapter and shared classifier.
4. Update the runbook coverage matrix and ignored evidence paths, preserving every still-manual protocol.
5. Add the protected manual/scheduled workflow after local live evidence passes and credential handling is reviewed.
6. Record one positive and one negative automated result for each runtime and verify strict OpenSpec plus deterministic tests.

Rollback removes the live workflow and harness while retaining captured release evidence according to policy and restoring the manual runbook as the sole live-runtime procedure. No onboarding files, state schema, deterministic tests, or runtime hooks require rollback.

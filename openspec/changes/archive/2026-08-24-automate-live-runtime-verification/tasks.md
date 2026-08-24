## 1. External Harness Contract

- [x] 1.1 Add a harness-discovered deterministic shell test with fake Claude and Codex executables covering exact-canary pass, negative-control pass, forbidden tool activity, malformed JSONL, timeout, non-zero runtime exit, and degraded capability status; run it first and verify it fails because the live harness is absent.
- [x] 1.2 Implement the minimal Python standard-library live command with runtime selection, disposable Git repositories, subprocess timeouts, separate case/evidence paths, source commit and dirty-state capture, and cleanup/retention controls; verify the focused fake-runtime isolation cases pass and the source repository remains byte-for-byte unchanged.
- [x] 1.3 Implement the fixed `case.json`, raw-stream, `result.json`, and `summary.json` evidence contract with hashing, credential exclusion, `pass`/`fail`/`degraded` verdicts, and exit codes 0/1/2; verify fixture-backed tests reject missing or malformed evidence and `--strict` converts degradation to failure.
- [x] 1.4 Add runtime executable, authentication, version, non-interactive mode, and structured-event capability probes without invoking a paid turn; verify fake missing and incompatible runtimes record decisive evidence and never return pass.

## 2. Native Onboarding Loading

- [x] 2.1 Add Claude Code positive and broken-import negative cases using fresh non-persistent sessions, `stream-json`, an unprompted generated canary, restricted setting sources, and disabled tools; verify fake streams cover exact-token success, token absence, tool-use rejection, and cross-session canary leakage.
- [x] 2.2 Add Codex positive and absent-`AGENTS.md` negative cases using `codex exec --json --ephemeral`, read-only isolation, an unprompted generated canary, and rejection of every tool-event path; verify fake JSONL covers exact-token success, token absence, tool-use rejection, and terminal error events.
- [x] 2.3 Run both native-load pairs against the installed supported runtimes, retain sanitized summaries and raw evidence, and verify each runtime's positive and negative verdict is decided by the harness with runtime version and source repository state recorded.

## 3. Lifecycle and Installation Evidence

- [x] 3.1 Add the inert scratch collector hook and Claude `SessionStart` plus `InstructionsLoaded` positive/silence pairs beside byte-identical copied production hooks; verify collector input, production repair context or debug log, valid-layout silence, and debug-off filesystem silence are independently attributable to each case.
- [x] 3.2 Add Claude `SubagentStart` managed/absent-onboarding and `PostToolUse` Git/non-Git pairs using structured runtime events and collector evidence; verify expected pointer or drift delivery, bounded silence, and explicit degraded status when runtime filtering spawns a self-gated hook.
- [x] 3.3 After `add-native-codex-lifecycle-hooks` is reconciled, add equivalent Codex session, subagent, and drift pairs against its packaged adapter and shared classifier; verify missing hooks report unavailable/degraded, qualifying cases deliver externally observed context, and non-qualifying cases never false-pass from absent evidence.
- [x] 3.4 Add no-model local-marketplace install cases for Claude Code and Codex using dedicated temporary runtime homes, including valid-plugin inventory and invalid-or-missing package rejection; verify neither case changes the maintainer's normal runtime configuration and keep public marketplace propagation documented as manual.

## 4. Runbook and Scheduled Execution

- [x] 4.1 Convert `docs/VERIFICATION.md` into an automated/partial/manual coverage map with harness case identifiers, authoritative evidence sources, and preserved steps for compaction survival, public marketplace propagation, and skill-reasoning protocols; verify every former protocol remains present or points to an executable case.
- [x] 4.2 Add ignored local evidence paths and concise README commands/claims for explicit live execution while preserving `tests/run.sh` as deterministic-only; verify a focused repository search finds no claim that normal tests launch authenticated runtimes and `bash tests/run.sh` makes no live-runtime invocation.
- [x] 4.3 Add a separate pinned GitHub Actions workflow with manual dispatch and low-frequency default-branch schedule, per-runtime jobs, concurrency and timeout bounds, protected invocation-scoped credentials, strict verdict handling, and sanitized artifact upload on failure; add a deterministic workflow contract test proving it has no pull-request/push trigger and does not expose credentials to general repository steps.

## 5. Final Proof

- [x] 5.1 Execute Codex `exec --json --ephemeral` native-loading positive and negative protocols plus the applicable `SessionStart`, `SubagentStart`, and `PostToolUse` collector pairs; inspect `summary.json` and decisive collector evidence to confirm no agent-authored success statement controls a verdict. Record invisible production `additionalContext` and Claude Code live coverage as partial/manual.
- [x] 5.2 Run the focused fake-runtime tests, existing full `bash tests/run.sh`, strict plugin validation, and `openspec validate automate-live-runtime-verification --strict`; fix only task-relevant failures and record any runtime capability that remains explicitly degraded or manual.

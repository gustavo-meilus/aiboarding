## 1. Define the one-cell canary

- [x] 1.1 Add a new maintained diagnostic profile for `command-discovery` x `aiboarding-full` x one repetition with `max_live_trials: 1`; verify deterministic manifest tests prove it has exactly one cell and historical v7 files remain unchanged.
- [x] 1.2 Freeze `gpt-5.6-luna`, low reasoning, disabled web search, ignored user configuration, ephemeral JSONL execution, workspace-write sandboxing, a bounded timeout, and zero retries in the diagnostic identity; verify contract tests reject drift or unspecified values.

## 2. Reuse the maintained execution gate

- [x] 2.1 Apply the frozen diagnostic controls through the existing Codex command path and retain the current independent grader/evidence flow; verify a fake adapter observes one invocation with the expected controls and no automatic retry.
- [x] 2.2 Point future maintained comparison expansion at the new diagnostic fingerprint while preserving historical profile identities; verify complete pass and complete objective fail permit only explicit expansion, incomplete evidence blocks it, and a viable canary never starts a comparison automatically.

## 3. Document and validate

- [x] 3.1 Update `docs/VERIFICATION.md` with deterministic checks, optional experimental prompt inspection, the explicit one-canary command, and the separate comparison decision; verify the protocol states that Luna proves plumbing only and that no comparison is required when no comparative claim is needed.
- [x] 3.2 Run focused benchmark tests and `bash tests/run.sh`; verify they pass without authentication or paid Codex execution and existing fail-closed packaging/reporting tests remain green.

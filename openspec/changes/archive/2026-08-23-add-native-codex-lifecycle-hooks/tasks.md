## 1. Shared Lifecycle Decisions

- [x] 1.1 Reconcile with `harden-onboarding-drift-classification`, implementing or reusing its one runtime-neutral classifier instead of adding Codex rules, and verify core tests cover in-sync, irrelevant, relevant, mixed, malformed, and rebased ranges.
- [x] 1.2 Make existing Claude drift delivery consume the shared classifier result without changing its event envelope, and verify `tests/hooks/test-drift-check.sh` plus an explicit Claude/Codex equivalent-input decision test pass.
- [x] 1.3 Extract runtime-neutral canonical/legacy/missing layout decisions and the bounded subagent pointer from Claude-specific emission, and verify existing session-start and subagent-start fixtures retain their outcomes and never emit document bodies.

## 2. Codex Hook Adapter and Packaging

- [x] 2.1 Add one Codex hook adapter that validates native stdin, resolves event `cwd` to the Git root, dispatches shared decisions, and emits Codex-native output; verify deterministic fixtures reject malformed or mismatched events without noise.
- [x] 2.2 Implement Codex `SessionStart` and `SubagentStart` dispatch through the adapter, and verify fixtures cover silent valid startup, missing and legacy reminders, absent-onboarding subagent silence, and a bounded `AGENTS.md` pointer.
- [x] 2.3 Implement Codex `PostToolUse` dispatch matched to `Bash`, self-gating on `tool_input.command` before shared classification, and verify fixtures cover non-Git silence, in-sync silence, irrelevant silence, relevant signal, and uncertain-state repair signal.
- [x] 2.4 Add plugin-bundled `hooks/hooks.json` and cross-platform commands using `PLUGIN_ROOT` plus `commandWindows`, and verify the hook file parses and every referenced handler resolves within the plugin root on Unix and Windows path fixtures.

## 3. Capability and Fallback Accuracy

- [x] 3.1 Point `.codex-plugin/plugin.json` at the shipped hook configuration, replace Claude-only lifecycle wording, and extend `tests/plugin/test-manifests.sh` so declared `Hooks` capability fails unless configuration, handlers, and shared helpers exist.
- [x] 3.2 Update create, migrate, and update runtime-awareness guidance so Codex plugin hooks are native but optional and copied standalone skills use manual `update-agent-onboarding`; verify a repository search finds no stale claim that drift nudging is always Claude-only.
- [x] 3.3 Update README and lifecycle documentation with Codex trust, disablement, unsupported-runtime fallback, and no-full-document-duplication behavior; verify all documented paths, event names, commands, and official Codex hook links resolve.

## 4. Verification and Compatibility

- [x] 4.1 Add a live Codex protocol covering plugin install, `/hooks` trust review, native `AGENTS.md` canary context, silent valid startup, minimal subagent pointer, non-Git silence, and relevant-versus-irrelevant Git drift delivery; verify the protocol records Codex version and pass/fail evidence without claiming an unrun result.
- [x] 4.2 Run Codex adapter, shared-core, existing Claude hook, manifest, and full `bash tests/run.sh` suites, fixing regressions until all pass while confirming portable skills still require no hook or Claude configuration.
- [x] 4.3 Run strict OpenSpec validation for `add-native-codex-lifecycle-hooks` and inspect packaged plugin contents, recording any live-runtime validation still pending rather than advertising unverified capability behavior.

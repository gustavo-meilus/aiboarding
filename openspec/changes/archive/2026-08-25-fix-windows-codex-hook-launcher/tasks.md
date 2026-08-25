## 1. Correct and Guard the Windows Launcher

- [x] 1.1 Update every `commandWindows` entry in `hooks/hooks.json` to invoke Bash with Bash-compatible `PLUGIN_ROOT` expansion, and verify the manifest retains all three lifecycle events and the `^Bash$` matcher.
- [x] 1.2 Extend deterministic plugin checks to reject PowerShell environment syntax in Bash commands and prove each Windows override resolves the shipped `hooks/codex-lifecycle` adapter, then verify `bash tests/plugin/test-manifests.sh` passes.
- [x] 1.3 Exercise the configured Windows-style launcher with supplied `PLUGIN_ROOT` and `PostToolUse` JSON, verifying a non-Git command remains silent while a relevant Git delta returns `<aiboarding-drift>` context without exit 127 via `bash tests/codex/test-codex-lifecycle.sh`.

## 2. Regression Verification

- [x] 2.1 Run `bash tests/run.sh` and `openspec validate fix-windows-codex-hook-launcher --strict`, verifying the full suite and strict change validation pass without changes to Claude/Caveman hook configuration or lifecycle semantics.

## 1. Portable Hook Launch

- [x] 1.1 Replace all Codex `commandWindows` values with the quoted native `cmd.exe` form that invokes the existing `run-hook.cmd`, retain the Unix/WSL Bash command, and verify `tests/plugin/test-manifests.sh` checks all three events and the `^Bash$` matcher.
- [x] 1.2 Harden `templates/hooks/run-hook.cmd` to dispatch the Codex adapter through Git for Windows Bash without falling through to the WSL Bash shim, synchronize `.aiboarding/hooks/run-hook.cmd`, and verify `tests/hooks/test-run-hook.sh` plus `tests/self-host/test-managed-repo.sh` cover dispatch, silent no-compatible-Bash fallback, and byte equality.
- [x] 1.3 Decode JSON-escaped backslashes in the Codex event `cwd` at the adapter boundary and verify `tests/codex/test-codex-lifecycle.sh` resolves a native Windows path while preserving malformed-input silence and existing lifecycle decisions.

## 2. Host Verification and Documentation

- [x] 2.1 Replace the Bash simulation of `commandWindows` with a Windows-gated `cmd.exe` execution of the exact manifest command, retain the Unix/WSL adapter fixture, and verify a native Windows path containing spaces delivers relevant drift context without exit 127 while non-Git input stays silent.
- [x] 2.2 Update `docs/VERIFICATION.md` with separate native Windows with Git Bash, native Windows without compatible Bash, and WSL/Unix checks, including Codex version, host, trust state, and manual-skill fallback evidence.
- [x] 2.3 Run `bash tests/run.sh`, `bash tests/self-host/test-managed-repo.sh`, and `openspec validate fix-portable-hook-runtime --strict`, verifying all deterministic, synchronization, and specification checks pass.

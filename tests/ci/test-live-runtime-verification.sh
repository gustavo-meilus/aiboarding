#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
workflow="$ROOT/.github/workflows/live-runtime-verification.yml"
content="$(<"$workflow")"
verifier="$(<"$ROOT/tests/live/verify_runtime.py")"
assert_contains "$content" 'workflow_dispatch:' 'live workflow is manual' || exit 1
assert_contains "$content" 'schedule:' 'live workflow has bounded schedule' || exit 1
assert_not_contains "$content" 'pull_request:' 'live workflow avoids pull requests' || exit 1
assert_not_contains "$content" 'push:' 'live workflow avoids pushes' || exit 1
assert_contains "$content" 'environment: live-runtime' 'live jobs use protected environment' || exit 1
assert_contains "$content" 'timeout-minutes: 10' 'live jobs have timeout' || exit 1
assert_not_contains "$content" 'ANTHROPIC_API_KEY' 'workflow has no Claude credential' || exit 1
assert_not_contains "$content" 'runtime claude' 'workflow has no Claude runtime job' || exit 1
assert_contains "$content" 'Run Codex lifecycle boundary canary' 'Codex gets invocation-scoped credential' || exit 1
assert_contains "$content" '--runtime codex --case positive --collect-hooks --install-plugin' 'workflow runs one installed positive Codex hook case' || exit 1
assert_contains "$verifier" 'gpt-5.6-luna' 'Codex command pins Luna' || exit 1
assert_contains "$verifier" 'model_reasoning_effort="low"' 'Codex command pins low reasoning' || exit 1
assert_not_contains "$verifier" '--ignore-user-config' 'Codex loads the disposable user layer' || exit 1
assert_contains "$verifier" 'aiboarding-codex-home-' 'Codex uses a disposable user layer' || exit 1
assert_contains "$verifier" 'codex_home / "hooks.json"' 'collector uses the trusted user hook layer' || exit 1
assert_contains "$verifier" '"{collector}"' 'collector path is passed explicitly to the hook' || exit 1
assert_contains "$verifier" 'aiboarding-user-prompt-submit.cmd' 'Windows collector uses a scratch trampoline' || exit 1
assert_contains "$verifier" 'command_windows = r".\aiboarding-user-prompt-submit.cmd"' 'Windows hook command is quote-free and scratch-relative' || exit 1
assert_contains "$verifier" '"%~dp0collector.sh" "%~dp0collector.jsonl"' 'Windows trampoline passes collector paths positionally' || exit 1
assert_contains "$verifier" 'templates" / "hooks" / "run-hook.cmd"' 'Windows trampoline reuses the hook wrapper' || exit 1
assert_contains "$verifier" 'web_search="disabled"' 'Codex disables web search' || exit 1
assert_contains "$verifier" '--ephemeral' 'Codex uses ephemeral mode' || exit 1
assert_contains "$verifier" '--json' 'Codex emits JSONL' || exit 1
assert_contains "$verifier" '"--sandbox", "read-only"' 'Codex uses read-only sandboxing' || exit 1
assert_contains "$content" 'if: always()' 'workflow retains evidence for every verdict' || exit 1
assert_not_contains "$content" 'retry' 'workflow has no retry' || exit 1
printf 'PASS: live runtime workflow\n'

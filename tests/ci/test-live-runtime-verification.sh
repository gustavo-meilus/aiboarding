#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
workflow="$ROOT/.github/workflows/live-runtime-verification.yml"
content="$(<"$workflow")"
assert_contains "$content" 'workflow_dispatch:' 'live workflow is manual' || exit 1
assert_contains "$content" 'schedule:' 'live workflow has bounded schedule' || exit 1
assert_not_contains "$content" 'pull_request:' 'live workflow avoids pull requests' || exit 1
assert_not_contains "$content" 'push:' 'live workflow avoids pushes' || exit 1
assert_contains "$content" 'environment: live-runtime' 'live jobs use protected environment' || exit 1
assert_contains "$content" 'timeout-minutes: 10' 'live jobs have timeout' || exit 1
assert_contains "$content" 'Run Claude native-load controls' 'Claude gets invocation-scoped credential' || exit 1
assert_contains "$content" 'Run Codex native-load controls' 'Codex gets invocation-scoped credential' || exit 1
printf 'PASS: live runtime workflow\n'

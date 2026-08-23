#!/usr/bin/env bash
set -euo pipefail
false # Ruleset canary: restored after blocked merge proof
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"

workflow="$ROOT/.github/workflows/executable-verification.yml"
[ -f "$workflow" ] || { printf 'FAIL: missing executable verification workflow\n'; exit 1; }
content="$(cat "$workflow")"

assert_contains "$content" 'pull_request:' 'workflow runs for pull requests' || exit 1
assert_contains "$content" 'push:' 'workflow runs for pushes' || exit 1
assert_contains "$content" 'branches: [main]' 'workflow targets main' || exit 1
assert_contains "$content" 'ubuntu-latest' 'workflow verifies Ubuntu' || exit 1
assert_contains "$content" 'windows-latest' 'workflow verifies Windows' || exit 1
assert_contains "$content" 'shell: bash' 'Windows job uses Git Bash' || exit 1
assert_contains "$content" 'GITHUB_SHA' 'workflow prints tested SHA' || exit 1
assert_contains "$content" 'bash tests/run.sh' 'workflow uses harness entry point' || exit 1

security="$(cat "$ROOT/.github/workflows/hol-plugin-scanner.yml")"
assert_contains "$security" 'pull_request:' 'security scan keeps pull-request trigger' || exit 1
assert_contains "$security" 'push:' 'security scan keeps push trigger' || exit 1
assert_contains "$security" 'fail_on_severity: high' 'security scan keeps failure threshold' || exit 1

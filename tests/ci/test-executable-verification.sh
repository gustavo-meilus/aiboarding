#!/usr/bin/env bash
set -euo pipefail
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

scanner_config="$ROOT/.plugin-scanner.toml"
[ -f "$scanner_config" ] || { printf 'FAIL: missing scanner config\n'; exit 1; }
config_content="$(cat "$scanner_config")"
assert_contains "$config_content" 'ignore_paths' 'scanner exclusions are path-scoped' || exit 1
assert_contains "$config_content" 'openspec/specs/agent-outcome-benchmarking/spec.md' 'scanner excludes known false-positive spec' || exit 1
if printf '%s' "$config_content" | grep -Eq 'disabled_rules|baseline_file|severity_overrides'; then
  printf 'FAIL: scanner config weakens rule policy\n'
  exit 1
fi
printf 'PASS: executable verification workflow\n'

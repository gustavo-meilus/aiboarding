#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
HOOK="$ROOT/templates/hooks/instructions-loaded"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

payload='{"hook_event_name":"InstructionsLoaded","file_path":"/proj/CLAUDE.md","load_reason":"session_start"}'

# 1. Debug flag unset: no stdout, no logs directory created.
out="$(printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$tmp" bash "$HOOK")"
assert_eq "$out" "" "silent without AIBOARDING_DEBUG" || exit 1
if [ -e "$tmp/.aiboarding/logs" ]; then
  printf 'FAIL: logs directory must not be created without the debug flag\n'; exit 1
fi

# 2. AIBOARDING_DEBUG=1: still no stdout; payload appended to the log.
out="$(printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$tmp" AIBOARDING_DEBUG=1 bash "$HOOK")"
assert_eq "$out" "" "no stdout even in debug mode" || exit 1
log="$(cat "$tmp/.aiboarding/logs/hooks.log")"
assert_contains "$log" '/proj/CLAUDE.md' "log contains the loaded file path" || exit 1
assert_contains "$log" 'session_start' "log contains the load reason" || exit 1
assert_contains "$log" 'instructions-loaded' "log names the hook" || exit 1

# 3. Second run appends rather than truncating.
payload2='{"hook_event_name":"InstructionsLoaded","file_path":"/proj/.claude/rules/testing.md","load_reason":"path_glob_match"}'
printf '%s' "$payload2" | CLAUDE_PROJECT_DIR="$tmp" AIBOARDING_DEBUG=1 bash "$HOOK" > /dev/null
log="$(cat "$tmp/.aiboarding/logs/hooks.log")"
assert_contains "$log" '/proj/CLAUDE.md' "first entry survives an append" || exit 1
assert_contains "$log" 'testing.md' "second entry appended" || exit 1

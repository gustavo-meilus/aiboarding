#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"

agents="$ROOT/AGENTS.md"
claude="$ROOT/CLAUDE.md"
state="$ROOT/.aiboarding/state.json"
config="$ROOT/.aiboarding/config.json"
settings="$ROOT/.claude/settings.json"

expected_sections='Project Purpose
Stack and Runtime
Build, Test, Run
Architecture Map
Domain Model
Agent Guardrails
Known Failure Modes
Verification Before Completion
Escalation - Ask the User When'
actual_sections="$(sed -n 's/^## //p' "$agents")"
assert_eq "$actual_sections" "$expected_sections" "AGENTS.md has canonical section schema" || exit 1

assert_contains "$(head -n 1 "$claude")" '@AGENTS.md' "CLAUDE.md imports AGENTS.md" || exit 1
assert_contains "$(cat "$claude")" '<!-- aiboarding-begin:claude-notes -->' "CLAUDE.md has managed notes block" || exit 1
assert_not_contains "$(cat "$claude")" '## Project Purpose' "CLAUDE.md does not duplicate canonical sections" || exit 1

bash "$ROOT/.aiboarding/tools/check-size-budget" "$agents"

for field in aiboarding_version canonical_file claude_wrapper generated last_synced_commit receipts; do
  assert_eq "$(grep -c "\"$field\"" "$state")" "1" "state has one $field field" || exit 1
done
assert_not_contains "$(cat "$config")" '"README.md"' "self-host config tracks README.md drift" || exit 1

for file in run-hook.cmd _lib session-start subagent-start drift-check instructions-loaded; do
  cmp -s "$ROOT/templates/hooks/$file" "$ROOT/.aiboarding/hooks/$file" || { printf 'FAIL: hook copy differs: %s\n' "$file"; exit 1; }
done
for file in inject-fenced check-size-budget check-preservation classify-drift lifecycle-decision audit-onboarding-evidence verify-onboarding-mutations write-evidence; do
  cmp -s "$ROOT/templates/tools/$file" "$ROOT/.aiboarding/tools/$file" || { printf 'FAIL: tool copy differs: %s\n' "$file"; exit 1; }
done

settings_content="$(cat "$settings")"
for hook in session-start subagent-start drift-check instructions-loaded; do
  assert_eq "$(grep -c "run-hook.cmd.* $hook" <<<"$settings_content")" "1" "settings has one managed $hook entry" || exit 1
done
assert_not_contains "$settings_content" 'pre-task' "settings has no retired pre-task entry" || exit 1
assert_not_contains "$settings_content" 'post-commit' "settings has no retired post-commit entry" || exit 1

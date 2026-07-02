#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
. "$ROOT/templates/hooks/_lib"

# --- JSON well-formedness (python3 when available; balance sanity otherwise) --
json_files="$ROOT/.claude-plugin/plugin.json
$ROOT/.claude-plugin/marketplace.json
$ROOT/templates/settings/hooks.json
$ROOT/templates/state/config.json
$ROOT/tests/fixtures/modern/.aiboarding/state.json
$ROOT/tests/fixtures/modern/.aiboarding/config.json"

while IFS= read -r f; do
  [ -f "$f" ] || { printf 'FAIL: missing JSON file %s\n' "$f"; exit 1; }
  if command -v python3 >/dev/null 2>&1; then
    if ! python3 -m json.tool "$f" >/dev/null 2>&1; then
      printf 'FAIL: invalid JSON in %s\n' "$f"; exit 1
    fi
  else
    # Fallback sanity: equal counts of braces and brackets.
    content="$(cat "$f")"
    open="${content//[^\{]/}"; close="${content//[^\}]/}"
    assert_eq "${#open}" "${#close}" "balanced braces in $f" || exit 1
  fi
done <<EOF
$json_files
EOF

# --- Required manifest keys ---------------------------------------------------
json_get "$ROOT/.claude-plugin/plugin.json" "name"
assert_eq "$REPLY" "aiboarding" "plugin.json has name" || exit 1
json_get "$ROOT/.claude-plugin/plugin.json" "version"
version="$REPLY"
case "$version" in
  [0-9]*.[0-9]*.[0-9]*) ;;
  *) printf 'FAIL: plugin.json version not semver-shaped: %s\n' "$version"; exit 1 ;;
esac
json_get "$ROOT/.claude-plugin/plugin.json" "license"
assert_eq "$REPLY" "MIT" "plugin.json declares the license" || exit 1

json_get "$ROOT/.claude-plugin/marketplace.json" "name"
assert_eq "$REPLY" "aiboarding" "marketplace.json has name" || exit 1
mk="$(cat "$ROOT/.claude-plugin/marketplace.json")"
assert_contains "$mk" '"source": "./"' "marketplace plugin entry sources the repo root" || exit 1
assert_not_contains "$mk" '$schema' "marketplace.json carries no unofficial \$schema URL" || exit 1

# CHANGELOG's published version should match the manifest.
assert_contains "$(cat "$ROOT/CHANGELOG.md")" "## ${version} " "CHANGELOG has an entry for the manifest version" || exit 1

# --- Skills: frontmatter contract (cross-agent portable subset) ---------------
for skill_md in "$ROOT"/skills/*/SKILL.md; do
  dir="$(basename "$(dirname "$skill_md")")"
  read_frontmatter "$skill_md" "name"
  assert_eq "$REPLY" "$dir" "skill name matches its directory ($dir)" || exit 1
  read_frontmatter "$skill_md" "description"
  if [ -z "$REPLY" ]; then
    printf 'FAIL: skill %s has no description\n' "$dir"; exit 1
  fi
done

# Expected skill set: five modern skills + two deprecated aliases.
for s in create-agent-onboarding update-agent-onboarding migrate-aiboarding \
         compress-onboarding audit-agent-onboarding create-aiboarding update-aiboarding; do
  [ -f "$ROOT/skills/$s/SKILL.md" ] || { printf 'FAIL: missing skill %s\n' "$s"; exit 1; }
done

# Aliases must self-describe as deprecated so auto-selection prefers new names.
read_frontmatter "$ROOT/skills/create-aiboarding/SKILL.md" "description"
assert_contains "$REPLY" "DEPRECATED" "create-aiboarding is marked deprecated" || exit 1
read_frontmatter "$ROOT/skills/update-aiboarding/SKILL.md" "description"
assert_contains "$REPLY" "DEPRECATED" "update-aiboarding is marked deprecated" || exit 1

# --- Settings template wiring --------------------------------------------------
settings="$(cat "$ROOT/templates/settings/hooks.json")"
for h in session-start subagent-start drift-check instructions-loaded; do
  assert_contains "$settings" "run-hook.cmd\\\" $h" "settings wire $h" || exit 1
done
assert_contains "$settings" '"if": "Bash(git *)"' "drift entry carries the if filter" || exit 1
assert_not_contains "$settings" 'pre-task' "no stale pre-task wiring" || exit 1
assert_not_contains "$settings" 'post-commit' "no stale post-commit wiring" || exit 1

# --- Template completeness: every file the create skill installs exists --------
for f in run-hook.cmd _lib session-start subagent-start drift-check instructions-loaded; do
  [ -f "$ROOT/templates/hooks/$f" ] || { printf 'FAIL: missing hook template %s\n' "$f"; exit 1; }
done
for f in inject-fenced check-size-budget check-preservation; do
  [ -f "$ROOT/templates/tools/$f" ] || { printf 'FAIL: missing tool template %s\n' "$f"; exit 1; }
done
for f in config.json dot-gitignore; do
  [ -f "$ROOT/templates/state/$f" ] || { printf 'FAIL: missing state template %s\n' "$f"; exit 1; }
done

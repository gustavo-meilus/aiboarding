#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
. "$ROOT/templates/hooks/_lib"

# escape_for_json escapes backslash, quote, newline, tab
out="$(escape_for_json "$(printf 'a"b\\c\n\tx')")"
assert_eq "$out" 'a\"b\\c\n\tx' "escape_for_json handles quote/backslash/newline/tab" || exit 1

# resolve_doc_path uses CLAUDE_PROJECT_DIR when set
CLAUDE_PROJECT_DIR="/tmp/proj" resolve_doc_path
assert_eq "$DOC_PATH" "/tmp/proj/AIBOARDING.md" "resolve_doc_path honors CLAUDE_PROJECT_DIR" || exit 1

# resolve_paths resolves the modern layout from CLAUDE_PROJECT_DIR
CLAUDE_PROJECT_DIR="/tmp/proj" resolve_paths
assert_eq "$AGENTS_PATH" "/tmp/proj/AGENTS.md" "resolve_paths sets AGENTS_PATH" || exit 1
assert_eq "$CLAUDE_MD_PATH" "/tmp/proj/CLAUDE.md" "resolve_paths sets CLAUDE_MD_PATH" || exit 1
assert_eq "$STATE_PATH" "/tmp/proj/.aiboarding/state.json" "resolve_paths sets STATE_PATH" || exit 1
assert_eq "$CONFIG_PATH" "/tmp/proj/.aiboarding/config.json" "resolve_paths sets CONFIG_PATH" || exit 1
assert_eq "$LEGACY_DOC_PATH" "/tmp/proj/AIBOARDING.md" "resolve_paths sets LEGACY_DOC_PATH" || exit 1

# json_get reads flat top-level scalar keys (aiboarding write contract)
tmp_json="$(mktemp)"
printf -- '{\n  "aiboarding_version": 2,\n  "last_synced_commit": "abc123",\n  "last_synced_commit_old": "WRONG",\n  "note": "escaped \\"quote\\" here",\n  "last_synced_commit": "SECOND"\n}\n' > "$tmp_json"
json_get "$tmp_json" "last_synced_commit"
assert_eq "$REPLY" "abc123" "json_get reads a string value, first match wins" || { rm -f "$tmp_json"; exit 1; }
json_get "$tmp_json" "aiboarding_version"
assert_eq "$REPLY" "2" "json_get reads a bare numeric value with trailing comma" || { rm -f "$tmp_json"; exit 1; }
json_get "$tmp_json" "note"
assert_eq "$REPLY" 'escaped "quote" here' "json_get unescapes embedded quotes" || { rm -f "$tmp_json"; exit 1; }
json_get "$tmp_json" "synced_commit"
assert_eq "$REPLY" "" "json_get does not substring-match key names" || { rm -f "$tmp_json"; exit 1; }
json_get "$tmp_json" "missing_key"
assert_eq "$REPLY" "" "json_get yields empty for a missing key" || { rm -f "$tmp_json"; exit 1; }
json_get "/nonexistent/file.json" "any"
assert_eq "$REPLY" "" "json_get yields empty for a missing file" || { rm -f "$tmp_json"; exit 1; }
rm -f "$tmp_json"

# json_get_array_items reads a one-item-per-line string array
tmp_arr="$(mktemp)"
printf -- '{\n  "empty": [],\n  "ignored_paths": [\n    "README.md",\n    "docs/archive/*"\n  ],\n  "after": "x"\n}\n' > "$tmp_arr"
json_get_array_items "$tmp_arr" "ignored_paths"
assert_eq "$REPLY" 'README.md
docs/archive/*
' "json_get_array_items reads items in order" || { rm -f "$tmp_arr"; exit 1; }
json_get_array_items "$tmp_arr" "empty"
assert_eq "$REPLY" "" "json_get_array_items yields empty for an inline empty array" || { rm -f "$tmp_arr"; exit 1; }
json_get_array_items "$tmp_arr" "missing"
assert_eq "$REPLY" "" "json_get_array_items yields empty for a missing key" || { rm -f "$tmp_arr"; exit 1; }
rm -f "$tmp_arr"

# path_matches_any glob matching (case-style; * crosses '/')
globs='README.md
docs/archive/*
.aiboarding/*'
if path_matches_any "README.md" "$globs"; then :; else
  printf 'FAIL: path_matches_any exact name\n'; exit 1
fi
if path_matches_any "docs/archive/deep/old.md" "$globs"; then :; else
  printf 'FAIL: path_matches_any subtree glob\n'; exit 1
fi
if path_matches_any ".aiboarding/state.json" "$globs"; then :; else
  printf 'FAIL: path_matches_any dot-dir glob\n'; exit 1
fi
if path_matches_any "src/main.ts" "$globs"; then
  printf 'FAIL: path_matches_any must not match unrelated path\n'; exit 1
fi
if path_matches_any "src/main.ts" ""; then
  printf 'FAIL: path_matches_any must not match on empty glob list\n'; exit 1
fi

# read_frontmatter extracts a value from a well-formed frontmatter block
tmp_fm="$(mktemp)"
printf -- '---\naiboarding_version: 1\nlast_synced_commit:   abc123  \n---\n# Body\nlast_synced_commit: NOT_THIS\n' > "$tmp_fm"
read_frontmatter "$tmp_fm" "last_synced_commit"
assert_eq "$REPLY" "abc123" "read_frontmatter reads frontmatter value and trims spaces" || { rm -f "$tmp_fm"; exit 1; }

# read_frontmatter ignores body lines when there is no frontmatter block
tmp_nofm="$(mktemp)"
printf -- '# Title\nlast_synced_commit: SHOULD_BE_IGNORED\n' > "$tmp_nofm"
read_frontmatter "$tmp_nofm" "last_synced_commit"
assert_eq "$REPLY" "" "read_frontmatter ignores body lines with no frontmatter" || { rm -f "$tmp_fm" "$tmp_nofm"; exit 1; }
rm -f "$tmp_fm" "$tmp_nofm"

# emit_cc_context produces the expected JSON shape with escaped content
out_json="$(emit_cc_context "SessionStart" "$(printf 'line1\n"q"')")"
assert_eq "$out_json" '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"line1\n\"q\""}}' "emit_cc_context emits escaped JSON" || exit 1

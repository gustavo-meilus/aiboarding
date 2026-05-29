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

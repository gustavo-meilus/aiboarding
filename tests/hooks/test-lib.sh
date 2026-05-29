#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
. "$ROOT/templates/hooks/_lib"

# escape_for_json escapes backslash, quote, newline, tab
out="$(escape_for_json "$(printf 'a"b\\c\n\tx')")"
assert_eq "$out" 'a\"b\\c\n\tx' "escape_for_json handles quote/backslash/newline/tab" || exit 1

# resolve_doc_path uses CLAUDE_PROJECT_DIR when set
CLAUDE_PROJECT_DIR="/tmp/proj" resolve_doc_path
assert_eq "$DOC_PATH" "/tmp/proj/AIBOARDING.md" "resolve_doc_path honors CLAUDE_PROJECT_DIR" || exit 1

#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
WRITER="$ROOT/templates/tools/write-evidence"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
git -C "$tmp" init -q; git -C "$tmp" config user.email t@t.t; git -C "$tmp" config user.name t
printf x > "$tmp/file"; git -C "$tmp" add file; git -C "$tmp" commit -qm base
head="$(git -C "$tmp" rev-parse HEAD)"
mkdir -p "$tmp/.aiboarding/tools"
printf '{\n  "last_synced_commit": "%s",\n  "receipts": [\n    {"file":"AGENTS.md","level":"full"}\n  ]\n}\n' "$head" > "$tmp/.aiboarding/state.json"
before="$(cat "$tmp/.aiboarding/state.json")"
cp "$WRITER" "$tmp/.aiboarding/tools/write-evidence"
printf '{"schema_version":1,"record_id":"migration:%s","type":"compression-verification","outcome":"pass","repository":{"identity":"example/repo","head":"%s"},"details":{"level":"full","bytes_before":2,"bytes_after":1,"lines_before":1,"lines_after":1,"preservation":"pass","size":"pass"}}\n' "$head" "$head" > "$tmp/record.json"
bash "$tmp/.aiboarding/tools/write-evidence" --project "$tmp" --record "$tmp/record.json" >/dev/null
assert_eq "$(cat "$tmp/.aiboarding/state.json")" "$before" 'evidence migration preserves state and receipts' || exit 1
find "$tmp/.aiboarding/evidence/v1" -name '*.json' | grep -q . || { echo 'FAIL: migrated record missing'; exit 1; }
rm "$tmp/.aiboarding/tools/write-evidence"
[ ! -e "$tmp/.aiboarding/tools/write-evidence" ] || { echo 'FAIL: writer removal failed'; exit 1; }
assert_eq "$(cat "$tmp/.aiboarding/state.json")" "$before" 'writer rollback preserves state' || exit 1
find "$tmp/.aiboarding/evidence/v1" -name '*.json' | grep -q . || { echo 'FAIL: rollback removed evidence'; exit 1; }
printf 'PASS: evidence migration\n'

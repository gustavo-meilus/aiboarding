#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
TOOL="$ROOT/templates/tools/write-evidence"
FIX="$ROOT/tests/fixtures/evidence"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
git -C "$tmp" init -q; git -C "$tmp" config user.email t@t.t; git -C "$tmp" config user.name t
printf 'x\n' > "$tmp/file"; git -C "$tmp" add file; git -C "$tmp" commit -qm base
head="$(git -C "$tmp" rev-parse HEAD)"
record="$tmp/record.json"
for fixture in "$FIX"/*.json; do
  cp "$fixture" "$record"
  bash "$TOOL" --project "$tmp" --record "$record" >/dev/null || { echo "FAIL: fixture rejected: $fixture"; exit 1; }
done
printf '{"schema_version":1,"record_id":"drift:%s","type":"drift-classification","outcome":"pass","repository":{"identity":"example/repo","base":"%s","head":"%s"},"details":{"disposition":"irrelevant","paths":[],"sections":[]}}\n' "$head" "$head" "$head" > "$record"
state_before="missing"; [ -f "$tmp/.aiboarding/state.json" ] && state_before="$(cat "$tmp/.aiboarding/state.json")"
out="$(bash "$TOOL" --project "$tmp" --record "$record")" || exit 1
[ -f "$out" ] || { echo 'FAIL: first write missing'; exit 1; }
out2="$(bash "$TOOL" --project "$tmp" --record "$record")" || exit 1
assert_eq "$out2" "$out" 'identical retry reuses record' || exit 1
for type in onboarding-validation compression-verification live-runtime-verification; do
  case "$type" in
    onboarding-validation) details='{"subjects":["AGENTS.md"],"validators":["preservation"]}' ;;
    compression-verification) details='{"level":"full","bytes_before":10,"bytes_after":8,"lines_before":2,"lines_after":1,"preservation":"pass","size":"pass"}' ;;
    live-runtime-verification) details='{"runtime":"codex","version":"1","protocol":"native-load","verdict":"degraded","evidence":["summary.json"]}' ;;
  esac
  printf '{"schema_version":1,"record_id":"%s:%s","type":"%s","outcome":"pass","repository":{"identity":"example/repo","head":"%s"},"details":%s}\n' "$type" "$head" "$type" "$head" "$details" > "$record"
  bash "$TOOL" --project "$tmp" --record "$record" >/dev/null || { echo "FAIL: valid $type rejected"; exit 1; }
done
printf '{"schema_version":1,"record_id":"drift:%s","type":"drift-classification","outcome":"fail","repository":{"identity":"example/repo","head":"%s"},"details":{"disposition":"irrelevant"}}\n' "$head" "$head" > "$record"
if bash "$TOOL" --project "$tmp" --record "$record" >/dev/null 2>&1; then echo 'FAIL: conflicting retry accepted'; exit 1; fi
for bad in '{"schema_version":1}' '{"schema_version":1,"record_id":"x","type":"drift-classification","outcome":"pass","repository":{"identity":"C:\\repo","head":"abc"},"details":{"raw_log":"no"}}'; do
  printf '%s\n' "$bad" > "$record"
  if bash "$TOOL" --project "$tmp" --record "$record" >/dev/null 2>&1; then echo 'FAIL: invalid evidence accepted'; exit 1; fi
done
assert_eq "${state_before}" missing 'writer preserves absent state' || exit 1
mkdir -p "$tmp/.aiboarding/evidence/v1"
printf partial > "$tmp/.aiboarding/evidence/v1/.interrupted.tmp"
printf '{"schema_version":1,"record_id":"retry:%s","type":"drift-classification","outcome":"pass","repository":{"identity":"example/repo","head":"%s"},"details":{"disposition":"irrelevant"}}\n' "$head" "$head" > "$record"
bash "$TOOL" --project "$tmp" --record "$record" >/dev/null || { echo 'FAIL: interrupted temp blocks retry'; exit 1; }
blocked="$(mktemp -d)"; printf x > "$blocked/.aiboarding"
if bash "$TOOL" --project "$blocked" --record "$record" >/dev/null 2>&1; then echo 'FAIL: unwritable destination accepted'; exit 1; fi
printf 'PASS: write-evidence\n'

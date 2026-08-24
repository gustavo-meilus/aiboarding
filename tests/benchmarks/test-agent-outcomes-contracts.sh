#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"; FIX="$ROOT/tests/fixtures/agent-outcomes/valid.json"
run() { python3 "$ROOT/benchmarks/agent-outcomes/benchmark.py" "$1"; }
run "$FIX"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
mutate() { python3 - "$FIX" "$tmp/$1.json" "$2" <<'PY'
import json, sys
source, target, mutation = sys.argv[1:]
value = json.load(open(source, encoding="utf-8"))
exec(mutation)
json.dump(value, open(target, "w", encoding="utf-8"))
PY
}
mutate missing_id 'value["tasks"][0]["id"] = ""'
! run "$tmp/missing_id.json" >/dev/null 2>&1
mutate undeclared 'value["experiment"]["identity"]["extra"] = "no"'
! run "$tmp/undeclared.json" >/dev/null 2>&1
mutate duplicate 'value["trials"].append(value["trials"][0].copy()); value["trials"][-1]["id"] = "trial-2"'
! run "$tmp/duplicate.json" >/dev/null 2>&1
mutate provenance 'value["trials"][0]["evidence"][0]["provenance"] = "unknown"'
! run "$tmp/provenance.json" >/dev/null 2>&1
mutate mutable 'value["experiment"]["identity"]["timeout"] = "21"'
! run "$tmp/mutable.json" >/dev/null 2>&1
for key in model runtime harness task fixture permissions tools budget timeout grader condition repetitions retry aggregation; do
  mutate "identity-$key" "value['experiment']['identity']['$key'] = 'changed'"
  ! run "$tmp/identity-$key.json" >/dev/null 2>&1
done
printf 'PASS: agent-outcome contracts\n'

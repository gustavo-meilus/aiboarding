#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"; FIX="$ROOT/tests/fixtures/agent-outcomes/valid.json"
run() { python3 "$ROOT/benchmarks/agent-outcomes/benchmark.py" "$1"; }
reject() { if run "$1" >/dev/null 2>&1; then return 1; fi; }
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
smoke="$ROOT/benchmarks/agent-outcomes/experiments/codex-maintained-outcomes-v8-canary.json"
mutate_profile() { python3 - "$smoke" "$tmp/$1.json" "$2" <<'PY'
import json, sys
source, target, mutation = sys.argv[1:]
value = json.load(open(source, encoding="utf-8"))
exec(mutation)
json.dump(value, open(target, "w", encoding="utf-8"))
PY
}
mutate_profile missing_execution 'del value["execution"]'
run "$tmp/missing_execution.json"
mutate_profile bad_execution 'value["execution"]["max_live_trials"] = 2'
! run "$tmp/bad_execution.json" >/dev/null 2>&1
run "$smoke"
for artifact in task condition grader; do
  mutate_profile "v3-$artifact-hash" "value['${artifact}s'][0]['sha256'] = '0' * 64"
  reject "$tmp/v3-$artifact-hash.json"
done
mutate_profile v3-combined "value['tasks'][0]['sha256'] = value['conditions'][0]['sha256'] = '0' * 64"
reject "$tmp/v3-combined.json"
mutate_sealed() { python3 - "$1" "$tmp/$2.json" <<'PY'
import json, sys
source, target = sys.argv[1:]
value = json.load(open(source, encoding="utf-8"))
value["tasks"][0]["sha256"] = "0" * 64
json.dump(value, open(target, "w", encoding="utf-8"))
PY
}
for profile in "$ROOT/benchmarks/agent-outcomes/experiments/codex-maintained-outcomes-v1.json" "$ROOT/benchmarks/agent-outcomes/experiments/codex-maintained-outcomes-v2.json" "$smoke"; do
  mutate_sealed "$profile" "sealed-$(basename "$profile")"
  reject "$tmp/sealed-$(basename "$profile").json"
done
artifact="$ROOT/benchmarks/agent-outcomes/tasks/command-discovery/task.json"
cp "$artifact" "$tmp/task.json"
printf '\n' >> "$artifact"
reject "$smoke"
mv "$tmp/task.json" "$artifact"
for key in model runtime harness task fixture permissions tools budget timeout grader condition repetitions retry aggregation; do
  mutate "identity-$key" "value['experiment']['identity']['$key'] = 'changed'"
  ! run "$tmp/identity-$key.json" >/dev/null 2>&1
done
for key in model reasoning_effort web_search ignore_user_config ephemeral jsonl sandbox timeout_seconds; do
  mutate_profile "codex-$key" "value['experiment']['identity']['codex']['$key'] = 'changed'"
  ! run "$tmp/codex-$key.json" >/dev/null 2>&1
done
mutate_profile missing-codex-control "del value['experiment']['identity']['codex']['web_search']"
! run "$tmp/missing-codex-control.json" >/dev/null 2>&1
python3 - "$ROOT/benchmarks/agent-outcomes/experiments/codex-maintained-outcomes-v7-smoke.json" <<'PY'
import json, sys
historical = json.load(open(sys.argv[1], encoding="utf-8"))
assert historical["experiment"]["fingerprint"] == "aeb07b8f7107962642208416ffc1e115c80f13e09250a13cecb55f150905b55a"
assert historical["execution"]["max_live_trials"] == len(historical["trials"]) == 12
PY
printf 'PASS: agent-outcome contracts\n'

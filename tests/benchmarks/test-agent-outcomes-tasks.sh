#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
python3 "$ROOT/benchmarks/agent-outcomes/tasks.py"
for pack in command-discovery architecture-boundary domain-invariant known-failure-mode escalation nested-instructions; do
  ! python3 "$ROOT/benchmarks/agent-outcomes/tasks/$pack/grader.py" "$ROOT/benchmarks/agent-outcomes/tasks/$pack/wrong" >/dev/null
done
python3 "$ROOT/benchmarks/agent-outcomes/tasks/escalation/grader.py" "$ROOT/benchmarks/agent-outcomes/tasks/escalation/reference-no-escalation"
! python3 "$ROOT/benchmarks/agent-outcomes/tasks/escalation/grader.py" "$ROOT/benchmarks/agent-outcomes/tasks/escalation/wrong-escalation" >/dev/null
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
cp -R "$ROOT/benchmarks/agent-outcomes/tasks" "$tmp/tasks"
rm "$tmp/tasks/escalation/task.json"
! python3 "$ROOT/benchmarks/agent-outcomes/tasks.py" "$tmp/tasks" >/dev/null 2>&1
for pack in command-discovery architecture-boundary domain-invariant known-failure-mode escalation nested-instructions; do
  cp -R "$ROOT/benchmarks/agent-outcomes/tasks" "$tmp/$pack"
  rm -rf "$tmp/$pack/$pack"
  ! python3 "$ROOT/benchmarks/agent-outcomes/tasks.py" "$tmp/$pack" >/dev/null 2>&1
done
for field in instruction expected_outcome permitted_environment applicable_conditions materiality grader wrong_reason; do
  cp -R "$ROOT/benchmarks/agent-outcomes/tasks" "$tmp/$field"
  python3 - "$tmp/$field/command-discovery/task.json" "$field" <<'PY'
import json, sys
p = sys.argv[1]; data = json.load(open(p)); data.pop(sys.argv[2]); json.dump(data, open(p, "w"))
PY
  ! python3 "$ROOT/benchmarks/agent-outcomes/tasks.py" "$tmp/$field" >/dev/null 2>&1
done
cp -R "$ROOT/benchmarks/agent-outcomes/tasks" "$tmp/leak"
printf 'leak\n' > "$tmp/leak/command-discovery/fixture/AGENTS.md"
! python3 "$ROOT/benchmarks/agent-outcomes/tasks.py" "$tmp/leak" >/dev/null 2>&1
printf 'PASS: sealed agent-outcome tasks\n'

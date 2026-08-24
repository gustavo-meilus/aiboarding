#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
python3 - "$ROOT/benchmarks/agent-outcomes/planner.py" <<'PY'
import importlib.util,sys
s=importlib.util.spec_from_file_location('planner',sys.argv[1]);m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
a=m.plan(['a','b'],['none','full','lite'],2,'fixture'); assert a==m.plan(['a','b'],['none','full','lite'],2,'fixture')
assert len({(x['task_id'],x['condition_id'],x['repetition']) for x in a})==12
assert [x['condition_id'] for x in a[:3]] != [x['condition_id'] for x in a[3:6]]
PY
printf 'PASS: randomized benchmark plan\n'

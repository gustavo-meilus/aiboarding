#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
python3 - "$ROOT/benchmarks/agent-outcomes/metrics.py" <<'PY'
import importlib.util,sys
s=importlib.util.spec_from_file_location('metrics',sys.argv[1]);m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
assert m.derive({})['task_success']['status']=='unavailable'
r=m.derive({'completion_status':[{'completion_claim':True}],'commands':[{'valid':False}],'grader':{'verdict':'fail'},'tool_calls':[],'retries':[],'timing':{'elapsed':1},'usage':{'status':'unavailable','reason':'runtime omits usage'},'interventions':[]})
assert r['false_completion']['value'] and r['invalid_commands']['value']==1 and r['usage']['status']=='unavailable'
PY
printf 'PASS: deterministic benchmark metrics\n'

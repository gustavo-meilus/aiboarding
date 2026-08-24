#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
python3 - "$ROOT/benchmarks/agent-outcomes/evidence.py" <<'PY'
import importlib.util,sys
s=importlib.util.spec_from_file_location('evidence',sys.argv[1]);m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
complete={k:[] for k in m.REQUIRED}; complete.update(task_id='task',condition_id='condition',experiment_fingerprint='fingerprint',final_tree='tree',completion='raw',completion_status='complete',grader={'definition':'grader-v1','verdict':'pass'},timing='timing',usage={'status':'unavailable','reason':'runtime omits usage'})
assert m.validate({})['status']=='incomplete'; assert m.validate({k:None for k in m.REQUIRED})['status']=='incomplete'; assert m.validate(complete)['status']=='complete'
assert m.regrade(complete, lambda definition, tree, commands: 'pass')['verdict']=='pass'; assert m.validate({**complete,'grader':{}})['status']=='incomplete'
PY
printf 'PASS: trial evidence contract\n'

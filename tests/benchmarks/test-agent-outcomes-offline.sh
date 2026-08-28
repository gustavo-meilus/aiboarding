#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"; tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
python3 - "$ROOT" "$tmp/results" <<'PY'
import json, shutil, sys
from pathlib import Path
root, output = map(Path, sys.argv[1:]); profile=json.loads((root/'benchmarks/agent-outcomes/experiments/codex-maintained-outcomes-v1.json').read_text())
for trial in profile['trials']:
    path=output/trial['task_id']/trial['condition_id']/str(trial['repetition']); (path/'final-tree').mkdir(parents=True)
    source=root/'benchmarks/agent-outcomes/tasks'/trial['task_id']/('reference-no-escalation' if trial['task_id']=='escalation' else 'reference')
    for item in source.rglob('*'):
        if item.is_file():
            target=path/'final-tree'/item.relative_to(source); target.parent.mkdir(parents=True,exist_ok=True); shutil.copy2(item,target)
    import hashlib
    controls=profile['experiment']['identity']; record={**trial,'final_tree':'retained','commands':[],'tool_calls':[],'completion':'done','completion_status':[],'grader':{'definition':'retained','verdict':'pass'},'timing':{'elapsed':1},'retries':[],'interventions':[],'usage':{'status':'unavailable','reason':'fixture'},'retention':{'status':'complete'},'identity':{'repository':trial['id'],'session':trial['id'],'controls_fingerprint':hashlib.sha256(json.dumps(controls,sort_keys=True,separators=(',',':')).encode()).hexdigest()}}
    (path/'trial.json').write_text(json.dumps(record))
PY
python3 "$ROOT/benchmarks/agent-outcomes/pilot.py" --profile "$ROOT/benchmarks/agent-outcomes/experiments/codex-maintained-outcomes-v1.json" --offline "$tmp/results" --output "$tmp/out"
python3 - "$ROOT" "$tmp/out" <<'PY'
import importlib.util,json,sys
from pathlib import Path
root,out=map(Path,sys.argv[1:]); summary=json.loads((out/'aggregate.json').read_text())['summary']; assert summary['complete']==108 and summary['incomplete']==0
s=importlib.util.spec_from_file_location('package',root/'benchmarks/agent-outcomes/package.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m);assert m.verify(out/'evidence.zip') and (out/'inventory.json').is_file()
PY
! python3 "$ROOT/benchmarks/agent-outcomes/pilot.py" --profile "$ROOT/benchmarks/agent-outcomes/experiments/codex-maintained-outcomes-v1.json" --offline "$ROOT/benchmarks/agent-outcomes/results/codex-command-discovery-v2" --output "$tmp/incomplete" >/dev/null 2>&1
test ! -f "$tmp/incomplete/evidence.zip"
python3 - "$tmp/results" <<'PY'
import json,sys
from pathlib import Path
trial=next(Path(sys.argv[1]).rglob('trial.json')); value=json.loads(trial.read_text()); value['identity']['controls_fingerprint']='drift'; trial.write_text(json.dumps(value))
PY
! python3 "$ROOT/benchmarks/agent-outcomes/pilot.py" --profile "$ROOT/benchmarks/agent-outcomes/experiments/codex-maintained-outcomes-v1.json" --offline "$tmp/results" --output "$tmp/drift" >/dev/null 2>&1
test ! -f "$tmp/drift/evidence.zip"
printf 'PASS: offline benchmark regeneration\n'

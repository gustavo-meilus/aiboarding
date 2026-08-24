#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
python3 - "$ROOT/benchmarks/agent-outcomes/aggregate.py" <<'PY'
import importlib.util,sys
s=importlib.util.spec_from_file_location('a',sys.argv[1]);m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
r=m.binary([True,False,None]); assert r['count']==2 and r['successes']==1 and r['wilson_95']; assert m.binary([])['rate'] is None
assert m.continuous([1,2,3,4])['median']==2.5
cells=m.matrix([{'task_id':'a','condition_id':'none','experiment_fingerprint':'one','success':True},{'task_id':'a','condition_id':'none','experiment_fingerprint':'two','success':False}], 'success'); assert len(cells)==2
PY
printf 'PASS: benchmark aggregation\n'

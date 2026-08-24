#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
python3 - "$ROOT/benchmarks/agent-outcomes/trials.py" <<'PY'
import importlib.util,sys
s=importlib.util.spec_from_file_location('trials',sys.argv[1]);m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
assert m.decide([{'status':'agent_failure'}], {'network'})=='final'; assert m.decide([{'status':'network'}], {'network'})=='retry'
attempts=m.record_attempt([], {'id':'one','status':'network'}); attempts=m.record_attempt(attempts, {'id':'two','status':'agent_failure'}); assert [x['id'] for x in attempts]==['one','two']
try:m.record_attempt(attempts, {'id':'two','status':'network'})
except ValueError:pass
else:raise AssertionError
try:m.decide([{'status':'pass'}],set(),True)
except ValueError:pass
else:raise AssertionError
assert m.intervention_stratum(True, True)=='intervened'; assert m.measurement(None,'runtime omitted usage')['status']=='unavailable'
try:m.measurement(None)
except ValueError:pass
else:raise AssertionError
PY
printf 'PASS: trial retry policy\n'

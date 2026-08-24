#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
python3 - "$ROOT/benchmarks/agent-outcomes/report.py" <<'PY'
import importlib.util,sys
s=importlib.util.spec_from_file_location('report',sys.argv[1]);m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
r=m.render([{'task':'command','condition':'aiboarding-full','success':'fail','evidence':'computed'},{'task':'command','condition':'stale','success':'pass','evidence':'inferred'}])
assert '| command | aiboarding-full | fail | computed |' in r and '| command | stale | pass | inferred |' in r and 'does not establish universal' in r
PY
printf 'PASS: loss-preserving benchmark report\n'

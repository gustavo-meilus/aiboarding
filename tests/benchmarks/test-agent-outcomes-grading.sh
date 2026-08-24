#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
python3 - "$ROOT/benchmarks/agent-outcomes/grading.py" <<'PY'
import importlib.util,sys
s=importlib.util.spec_from_file_location('grading',sys.argv[1]);m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
base={'grader_id':'task-grader-v1'}
assert m.verdict([{**base,'provenance':'computed','verdict':'fail'},{**base,'provenance':'inferred','verdict':'pass'}])=='fail'
assert m.verdict([{**base,'provenance':'computed','status':'timeout'}])=='incomplete'
assert m.normalize({**base,'provenance':'computed','status':'error'})['verdict']=='incomplete'
PY
printf 'PASS: objective grader authority\n'

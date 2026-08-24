#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"; tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
printf 'fixture\n' > "$tmp/source"
python3 - "$ROOT/benchmarks/agent-outcomes/runner.py" "$tmp" <<'PY'
import importlib.util, pathlib, shutil, sys
s=importlib.util.spec_from_file_location('runner',sys.argv[1]);m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
p,e=m.prepare(pathlib.Path(sys.argv[2]), {'AGENTS.md':'frozen\n'}, 'a'*64); q,f=m.prepare(pathlib.Path(sys.argv[2]), {'AGENTS.md':'other\n'}, 'a'*64); assert (p/'AGENTS.md').read_text()=='frozen\n'; assert (q/'AGENTS.md').read_text()=='other\n'; assert (p/'.git').is_dir(); assert e['experiment_fingerprint']=='a'*64 and e['session']!=f['session']; shutil.rmtree(p); shutil.rmtree(q)
identity, result=m.run_trial(pathlib.Path(sys.argv[2]), {'AGENTS.md':'selected\n'}, 'a'*64, lambda scratch, identity: ((scratch/'AGENTS.md').read_text(), scratch))
assert result[0]=='selected\n' and not result[1].exists() and identity['experiment_fingerprint']=='a'*64
assert pathlib.Path(sys.argv[2],'source').read_text()=='fixture\n'
pack=pathlib.Path(sys.argv[1]).parent/'tasks'/'command-discovery'; condition=pathlib.Path(sys.argv[1]).parents[2]/'tests'/'fixtures'/'agent-outcomes'/'conditions'/'none.json'
identity, result=m.run_pack(pack, condition, 'a'*64, lambda scratch, instruction, identity: (instruction, (scratch/'README.md').is_file()))
assert result==('Use the repository\'s documented check.', True) and identity['experiment_fingerprint']=='a'*64
PY
printf 'PASS: benchmark runner reuses live isolation\n'

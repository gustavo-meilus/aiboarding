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
assert result[1] and identity['experiment_fingerprint']=='a'*64
assert identity['controls_fingerprint'] == __import__('hashlib').sha256(b'{}').hexdigest()
PY
python3 - "$ROOT" <<'PY'
import importlib.util, json, pathlib, sys
root=pathlib.Path(sys.argv[1]); pilot_path=root/'benchmarks/agent-outcomes/pilot.py'
s=importlib.util.spec_from_file_location('pilot',pilot_path); m=importlib.util.module_from_spec(s); s.loader.exec_module(m)
profile=json.loads((root/'benchmarks/agent-outcomes/experiments/codex-maintained-outcomes-v1.json').read_text())
benchmark_path=root/'benchmarks/agent-outcomes/benchmark.py'; s=importlib.util.spec_from_file_location('benchmark',benchmark_path); benchmark=importlib.util.module_from_spec(s); s.loader.exec_module(benchmark)
smoke=json.loads((root/'benchmarks/agent-outcomes/experiments/codex-maintained-outcomes-v8-canary.json').read_text()); benchmark.validate(smoke)
broken={**smoke,'conditions':smoke['conditions'][1:]}
try: benchmark.validate(broken); raise AssertionError('missing smoke condition accepted')
except ValueError: pass
seen=[]
def fake(scratch, instruction, identity):
    seen.append((identity['session'], identity['controls_fingerprint'], (scratch/'AGENTS.md').exists()))
    return 'fake'
assert len(m.run_profile(profile, fake)) == 108
assert len({session for session, _, _ in seen}) == 108
assert len({controls for _, controls, _ in seen}) == 1
assert any(applied for _, _, applied in seen)
complete={"evidence_status":"complete","objective_verdict":"fail"}
records={(cell['task_id'],cell['condition_id'],cell['repetition']):complete for cell in m.profile_cells(smoke)}
gate=m.diagnostic_gate(smoke, records); assert gate['viable'] and gate['complete']==1 and gate['incomplete']==[]
records.pop(next(iter(records))); gate=m.diagnostic_gate(smoke, records); assert not gate['viable'] and len(gate['incomplete'])==1
comparison=json.loads((root/'benchmarks/agent-outcomes/experiments/codex-maintained-outcomes-v6.json').read_text())
try: m.expansion_allowed(comparison, None); raise AssertionError('comparison started without explicit diagnostic')
except ValueError: pass
gate_path=pathlib.Path(sys.argv[1])/'tests'/'fixtures'/'agent-outcomes'/'diagnostic-gate.json'; gate_path.write_text(json.dumps({"profile":smoke['experiment']['fingerprint'],"viable":True}))
m.expansion_allowed(comparison, gate_path)
gate_path.write_text(json.dumps({"profile":smoke['experiment']['fingerprint'],"viable":False}))
try: m.expansion_allowed(comparison, gate_path); raise AssertionError('incomplete diagnostic expanded')
except ValueError: pass
gate_path.unlink()
events=m.sanitized_events('{"type":"item.completed","item":{"id":"1","type":"agent_message","text":"C:\\\\Users\\\\secret"}}\n{"type":"item.completed","item":{"id":"2","type":"command_execution","command":"type C:\\\\Users\\\\secret\\\\token"}}', pathlib.Path('C:/scratch'))
assert len(events)==1 and events[0]['item']['command'].startswith('sha256:')
class Result:
    def __init__(self, code=0, stdout='', stderr=''): self.returncode,self.stdout,self.stderr=code,stdout,stderr
commands=[]
def fake_run(command, **kwargs):
    commands.append((command, kwargs))
    return Result(stdout='codex test') if command[:2] == ['codex', '--version'] else Result(1 if pathlib.Path(command[0]).name == 'grader.py' else 0, None, None)
m.subprocess.run=fake_run
output=pathlib.Path(sys.argv[1])/'tests'/'fixtures'/'agent-outcomes'/'pilot-retention'
trial=m.execute(root/'benchmarks/agent-outcomes/tasks/command-discovery', root/'benchmarks/agent-outcomes/conditions/command-discovery/aiboarding-full.json', 'a'*64, output, 1, None, 1, smoke['experiment']['identity'])
assert trial['retention']['status']=='incomplete' and next(output.rglob('trial.json')).is_file()
command, kwargs=next((command, kwargs) for command, kwargs in commands if command[:2] == ['codex', 'exec'])
assert command[:8] == ['codex', 'exec', '--json', '--ephemeral', '--ignore-user-config', '--sandbox', 'workspace-write', '-C']
assert ['--model', 'gpt-5.6-luna'] == command[9:11] and command[11:13] == ['-c', 'model_reasoning_effort="low"'] and '--search' not in command and kwargs['timeout'] == 60
__import__('shutil').rmtree(output)
PY
printf 'PASS: benchmark runner reuses live isolation\n'

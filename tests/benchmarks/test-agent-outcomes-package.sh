#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"; tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/root"; printf safe > "$tmp/root/result.json"; printf no > "$tmp/root/token"
python3 - "$ROOT/benchmarks/agent-outcomes/package.py" "$tmp" <<'PY'
import importlib.util,pathlib,sys
s=importlib.util.spec_from_file_location('package',sys.argv[1]);m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
root=pathlib.Path(sys.argv[2])/'root'; bundle=pathlib.Path(sys.argv[2])/'evidence.zip'
result=m.package(root,['result.json'],bundle); assert result['artifacts'][0]['path']=='result.json' and m.verify(bundle)
try:m.package(root,['token'],bundle)
except ValueError:pass
else:raise AssertionError
with __import__('zipfile').ZipFile(bundle,'a') as archive: archive.writestr('result.json',b'tampered')
assert not m.verify(bundle)
PY
printf 'PASS: sanitized evidence package\n'

#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"; FIX="$ROOT/tests/fixtures/agent-outcomes/conditions"
python3 - "$ROOT/benchmarks/agent-outcomes/conditions.py" "$FIX/matrix.json" <<'PY'
import importlib.util, sys
s=importlib.util.spec_from_file_location("conditions",sys.argv[1]); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); m.validate_matrix(__import__('pathlib').Path(sys.argv[2]))
PY
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
for source in "$FIX"/*.json; do
  name="$(basename "$source" .json)"
  [ "$name" = matrix ] && continue
  python3 "$ROOT/benchmarks/agent-outcomes/conditions.py" "$source" "$tmp/$name.json"
done
cmp "$tmp/aiboarding-full.json" <(python3 "$ROOT/benchmarks/agent-outcomes/conditions.py" "$FIX/aiboarding-full.json" "$tmp/repeated.json" && cat "$tmp/repeated.json")
python3 - "$ROOT/benchmarks/agent-outcomes/conditions.py" <<'PY'
import importlib.util, sys
spec = importlib.util.spec_from_file_location("conditions", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
assert m.cut("éx".encode(), 1) == b""
assert m.cut("éx".encode(), 2) == "é".encode()
assert m.cut(b"x", 4) == b"x"
PY
cp "$FIX/contradictory.json" "$tmp/bad.json"; sed -i 's/cross-file-contradiction//g' "$tmp/bad.json"
! python3 "$ROOT/benchmarks/agent-outcomes/conditions.py" "$tmp/bad.json" "$tmp/out.json" >/dev/null 2>&1
cp "$FIX/truncate-9.json" "$tmp/too-large.json"; sed -i 's/"budget":9/"budget":1/' "$tmp/too-large.json"
! python3 "$ROOT/benchmarks/agent-outcomes/conditions.py" "$tmp/too-large.json" "$tmp/out.json" >/dev/null 2>&1
printf 'PASS: frozen agent-outcome conditions\n'

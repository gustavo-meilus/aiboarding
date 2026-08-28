import json, sys
from pathlib import Path
task = json.loads(Path(__file__).with_name("task.json").read_text())
root = Path(sys.argv[1])
ok = all((root / name).is_file() and (root / name).read_text(encoding="utf-8") == expected for name, expected in task["expected_files"].items())
if not ok: print(task["wrong_reason"])
raise SystemExit(0 if ok else 1)

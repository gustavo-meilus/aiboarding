import json, sys
from pathlib import Path
task = json.loads(Path(__file__).with_name("task.json").read_text()); root = Path(sys.argv[1])
ok = (root / "nested/result.txt").read_text(encoding="utf-8") == "nested\n" if (root / "nested/result.txt").is_file() else False
if not ok: print(task["wrong_reason"])
raise SystemExit(0 if ok else 1)

import json, sys
from pathlib import Path
task = json.loads(Path(__file__).with_name("task.json").read_text()); root = Path(sys.argv[1])
try: ok = json.loads((root / "account.json").read_text())["balance"] >= 0
except (OSError, ValueError, KeyError, TypeError): ok = False
if not ok: print(task["wrong_reason"])
raise SystemExit(0 if ok else 1)

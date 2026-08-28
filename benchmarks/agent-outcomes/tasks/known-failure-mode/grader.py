import json, sys
from pathlib import Path
task = json.loads(Path(__file__).with_name("task.json").read_text()); root = Path(sys.argv[1])
try: ok = json.loads((root / "settings.json").read_text())["safe_mode"] is True
except (OSError, ValueError, KeyError): ok = False
if not ok: print(task["wrong_reason"])
raise SystemExit(0 if ok else 1)

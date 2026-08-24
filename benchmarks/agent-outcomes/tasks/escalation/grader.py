import json, sys
from pathlib import Path
ok = (Path(sys.argv[1]) / "outcome").read_text().strip() == "PASS"
if not ok: print(json.loads(Path(__file__).with_name("task.json").read_text())["wrong_reason"])
raise SystemExit(0 if ok else 1)

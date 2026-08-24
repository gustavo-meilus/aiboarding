from pathlib import Path

raise SystemExit(0 if not any("domain" in path.read_text(encoding="utf-8") for path in Path(".").glob("*.py")) else 1)

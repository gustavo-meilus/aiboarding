from pathlib import Path

raise SystemExit(0 if Path("README.md").is_file() else 1)

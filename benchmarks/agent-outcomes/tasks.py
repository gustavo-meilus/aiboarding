#!/usr/bin/env python3
"""Validate sealed, deterministic benchmark task packs."""
from __future__ import annotations

import json
import sys
from pathlib import Path

REQUIRED = {"command-discovery", "architecture-boundary", "domain-invariant", "known-failure-mode", "escalation", "nested-instructions"}


def main() -> int:
    root = Path(sys.argv[1]) if len(sys.argv) == 2 else Path(__file__).with_name("tasks")
    categories: set[str] = set()
    try:
        for pack in sorted(root.iterdir()):
            manifest = json.loads((pack / "task.json").read_text(encoding="utf-8"))
            for key in ("id", "category", "instruction", "expected_outcome", "permitted_environment", "applicable_conditions", "materiality", "wrong_reason", "grader"):
                if not manifest.get(key): raise ValueError(f"{pack.name}: missing {key}")
            if not (pack / "fixture").is_dir() or not (pack / "agent-instructions.md").is_file() or not (pack / "grader.py").is_file(): raise ValueError(f"{pack.name}: unsealed fixture or grader")
            if any(path.name == "grader.py" for path in (pack / "fixture").rglob("*")): raise ValueError(f"{pack.name}: grader visible to agent")
            if manifest["category"] == "nested-instructions":
                if manifest.get("verified_precedence") is not True or not (pack / "fixture" / "nested" / "AGENTS.md").is_file():
                    raise ValueError(f"{pack.name}: nested precedence is not verified")
            elif any(path.name == "AGENTS.md" for path in (pack / "fixture").rglob("*")):
                raise ValueError(f"{pack.name}: undeclared instruction file")
            for control, expected in (("reference", 0), ("wrong", 1)):
                result = __import__("subprocess").run([sys.executable, str(pack / "grader.py"), str(pack / control)], text=True, capture_output=True)
                code = result.returncode
                if code != expected: raise ValueError(f"{pack.name}: {control} control")
                if control == "wrong" and manifest["wrong_reason"] not in result.stdout: raise ValueError(f"{pack.name}: wrong control reason")
            if manifest["category"] == "escalation":
                for control, expected in (("reference-no-escalation", 0), ("wrong-escalation", 1)):
                    if __import__("subprocess").run([sys.executable, str(pack / "grader.py"), str(pack / control)], capture_output=True).returncode != expected:
                        raise ValueError(f"{pack.name}: {control} control")
            categories.add(manifest["category"])
        if categories != REQUIRED: raise ValueError("missing required task categories")
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"benchmark tasks: {error}", file=sys.stderr); return 2
    return 0


if __name__ == "__main__": raise SystemExit(main())

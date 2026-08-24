#!/usr/bin/env python3
"""Freeze prebuilt instruction bundles; never generate context during trials."""
from __future__ import annotations
import hashlib, json, sys
from pathlib import Path

REQUIRED = {"none", "manual-minimal", "aiboarding-off", "aiboarding-lite", "aiboarding-full", "aiboarding-ultra", "stale", "contradictory"}

def digest(data: bytes) -> str: return hashlib.sha256(data).hexdigest()
def cut(data: bytes, budget: int) -> bytes:
    if budget < 0: raise ValueError("negative budget")
    return data[:budget].decode("utf-8", "ignore").encode("utf-8")

def freeze(source: Path, output: Path) -> None:
    value = json.loads(source.read_text(encoding="utf-8"))
    condition_id = value.get("id")
    if value.get("schema_version") != 1 or not isinstance(condition_id, str) or (condition_id not in REQUIRED and not condition_id.startswith("truncate-")):
        raise ValueError("invalid condition identity")
    files = value.get("files", {})
    if not isinstance(files, dict): raise ValueError("missing files")
    if any(not isinstance(name, str) or not isinstance(text, str) for name, text in files.items()): raise ValueError("invalid file mapping")
    rendered = {name: text.encode("utf-8") for name, text in files.items()}
    if value["id"] == "none" and rendered: raise ValueError("none must not deliver files")
    if value["id"] == "contradictory" and not value.get("mutation_scenario_id"): raise ValueError("contradictory requires scenario")
    if value["id"] == "stale" and not value.get("source_revision"): raise ValueError("stale requires revision")
    if condition_id.startswith("truncate-"):
        if not isinstance(value.get("budget"), int) or not isinstance(value.get("source_condition"), str) or not isinstance(value.get("file_mapping"), dict):
            raise ValueError("truncation requires budget, source, and file mapping")
        if sum(len(data) for data in rendered.values()) > value["budget"]: raise ValueError("truncation exceeds budget")
    bundle = {"schema_version": 1, "id": condition_id, "provenance": value.get("provenance", {}), "files": {name: {"sha256": digest(data), "bytes": len(data)} for name, data in sorted(rendered.items())}, "measured_tokens": {"status": "unavailable", "reason": "no runtime tokenizer"}}
    if condition_id.startswith("truncate-"): bundle["truncation"] = {key: value[key] for key in ("budget", "source_condition", "file_mapping")}
    bundle["sha256"] = digest(json.dumps(bundle, sort_keys=True, separators=(",", ":")).encode())
    output.write_text(json.dumps(bundle, indent=2, sort_keys=True) + "\n", encoding="utf-8")

def validate_matrix(path: Path) -> None:
    value = json.loads(path.read_text(encoding="utf-8")); required = REQUIRED - {"stale", "contradictory"}
    for task, conditions in value.get("tasks", {}).items():
        if not task or not required <= set(conditions): raise ValueError("missing supported condition")

if __name__ == "__main__":
    try: freeze(Path(sys.argv[1]), Path(sys.argv[2]))
    except (IndexError, OSError, ValueError, json.JSONDecodeError) as error: print(f"conditions: {error}", file=sys.stderr); raise SystemExit(2)

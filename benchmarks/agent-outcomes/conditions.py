#!/usr/bin/env python3
"""Freeze task-independent onboarding inputs before benchmark execution."""
from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

REQUIRED = {"none", "manual-minimal", "aiboarding-off", "aiboarding-lite", "aiboarding-full", "aiboarding-ultra", "stale", "contradictory"}
MAX_BYTES = 64 * 1024


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def cut(data: bytes, budget: int) -> bytes:
    if budget < 0:
        raise ValueError("negative budget")
    return data[:budget].decode("utf-8", "ignore").encode("utf-8")


def _source(value: dict) -> tuple[str, dict[str, str]]:
    condition_id = value.get("id")
    if value.get("schema_version") != 1 or not isinstance(condition_id, str) or (condition_id not in REQUIRED and not condition_id.startswith("truncate-")):
        raise ValueError("invalid condition identity")
    files = value.get("files", {})
    if not isinstance(files, dict) or any(not isinstance(name, str) or not isinstance(text, str) for name, text in files.items()):
        raise ValueError("invalid file mapping")
    if any(Path(name).is_absolute() or ".." in Path(name).parts for name in files):
        raise ValueError("unsafe file mapping")
    if sum(len(text.encode()) for text in files.values()) > MAX_BYTES:
        raise ValueError("condition exceeds size limit")
    if condition_id == "none" and files:
        raise ValueError("none must not deliver files")
    if condition_id == "contradictory" and not value.get("mutation_scenario_id"):
        raise ValueError("contradictory requires scenario")
    if condition_id == "stale" and not value.get("source_revision"):
        raise ValueError("stale requires revision")
    if condition_id.startswith("truncate-"):
        if not isinstance(value.get("budget"), int) or not isinstance(value.get("source_condition"), str) or not isinstance(value.get("file_mapping"), dict):
            raise ValueError("truncation requires budget, source, and file mapping")
        if sum(len(text.encode()) for text in files.values()) > value["budget"]:
            raise ValueError("truncation exceeds budget")
    return condition_id, files


def freeze(source: Path, output: Path) -> None:
    value = json.loads(source.read_text(encoding="utf-8"))
    condition_id, files = _source(value)
    frozen = {
        "schema_version": 2,
        "id": condition_id,
        "source": {"path": source.name, "sha256": digest(source.read_bytes())},
        "provenance": value.get("provenance", {}),
        "files": {name: {"content": text, "sha256": digest(text.encode()), "bytes": len(text.encode())} for name, text in sorted(files.items())},
        "measured_tokens": {"status": "unavailable", "reason": "no runtime tokenizer"},
    }
    for key in ("source_revision", "mutation_scenario_id"):
        if key in value:
            frozen[key] = value[key]
    if condition_id.startswith("truncate-"):
        frozen["truncation"] = {key: value[key] for key in ("budget", "source_condition", "file_mapping")}
    frozen["sha256"] = digest(json.dumps(frozen, sort_keys=True, separators=(",", ":")).encode())
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(frozen, indent=2, sort_keys=True) + "\n", encoding="utf-8", newline="\n")


def validate_matrix(path: Path) -> None:
    value = json.loads(path.read_text(encoding="utf-8"))
    for task, conditions in value.get("tasks", {}).items():
        if not task or not REQUIRED <= set(conditions):
            raise ValueError("missing supported condition")


def contents(value: dict) -> dict[str, str]:
    """Accept old readable v1 sources and immutable v2 bundles."""
    if value.get("schema_version") == 1:
        return _source(value)[1]
    files = value.get("files")
    if value.get("schema_version") != 2 or not isinstance(files, dict):
        raise ValueError("invalid frozen bundle")
    result = {}
    for name, item in files.items():
        if not isinstance(item, dict) or not isinstance(item.get("content"), str) or item.get("sha256") != digest(item["content"].encode()):
            raise ValueError("corrupt frozen bundle")
        result[name] = item["content"]
    copy = dict(value); copy.pop("sha256", None)
    if value.get("sha256") != digest(json.dumps(copy, sort_keys=True, separators=(",", ":")).encode()):
        raise ValueError("frozen bundle hash mismatch")
    return result


if __name__ == "__main__":
    try:
        freeze(Path(sys.argv[1]), Path(sys.argv[2]))
    except (IndexError, OSError, ValueError, json.JSONDecodeError) as error:
        print(f"conditions: {error}", file=sys.stderr)
        raise SystemExit(2)

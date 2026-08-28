"""Fail-closed benchmark trial evidence validation and offline regrading."""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

REQUIRED = {"task_id", "condition_id", "experiment_fingerprint", "final_tree", "commands",
            "tool_calls", "completion", "completion_status", "grader", "timing", "retries",
            "interventions", "usage", "retention"}


def validate(record):
    missing = {key for key in REQUIRED if record.get(key) is None or (isinstance(record.get(key), str) and not record[key])}
    if missing:
        return {"status": "incomplete", "reason": "missing " + ", ".join(sorted(missing))}
    if not isinstance(record["commands"], list) or not isinstance(record["tool_calls"], list):
        return {"status": "incomplete", "reason": "malformed action evidence"}
    identity = record.get("identity")
    if identity is not None and (not isinstance(identity, dict) or not identity.get("repository") or not identity.get("session") or not identity.get("controls_fingerprint")):
        return {"status": "incomplete", "reason": "malformed execution identity"}
    if not isinstance(record["grader"], dict) or not record["grader"].get("definition") or record["grader"].get("verdict") not in {"pass", "fail"}:
        return {"status": "incomplete", "reason": "malformed decisive grader evidence"}
    if not isinstance(record["timing"], dict) or record["timing"].get("elapsed") is None:
        return {"status": "incomplete", "reason": "malformed timing evidence"}
    if not isinstance(record["usage"], dict) or record["usage"].get("status") not in {"observed", "unavailable"}:
        return {"status": "incomplete", "reason": "malformed usage evidence"}
    if record["usage"]["status"] == "unavailable" and not record["usage"].get("reason"):
        return {"status": "incomplete", "reason": "missing usage limitation"}
    if not isinstance(record["retention"], dict) or record["retention"].get("status") not in {"complete", "incomplete"}:
        return {"status": "incomplete", "reason": "malformed retained-state evidence"}
    if record["retention"]["status"] != "complete":
        return {"status": "incomplete", "reason": record["retention"].get("reason", "incomplete retained state")}
    return {"status": "complete"}


def regrade(record, grader):
    """Invoke a retained task-local grader without a runtime or model."""
    result = validate(record)
    if result["status"] != "complete":
        return result
    verdict = grader(record["grader"]["definition"], record["final_tree"], record["commands"])
    return {"status": "complete", "verdict": verdict}


def regrade_snapshot(record, grader: Path, snapshot: Path):
    """Rerun the retained task-local grader without model or runtime access."""
    result = validate(record)
    if result["status"] != "complete" or not grader.is_file() or not snapshot.is_dir():
        return {"status": "incomplete", "reason": "missing retained grader input"}
    try:
        process = subprocess.run([sys.executable, str(grader), str(snapshot)], capture_output=True, text=True, timeout=10)
    except (OSError, subprocess.TimeoutExpired):
        return {"status": "incomplete", "reason": "grader error or timeout"}
    verdict = "pass" if process.returncode == 0 else "fail"
    if verdict != record["grader"]["verdict"]:
        return {"status": "incomplete", "reason": "retained grader verdict drift"}
    return {"status": "complete", "verdict": verdict}

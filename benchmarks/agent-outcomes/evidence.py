"""Fail-closed benchmark trial evidence validation and offline regrading."""

REQUIRED = {"task_id", "condition_id", "experiment_fingerprint", "final_tree", "commands",
            "tool_calls", "completion", "completion_status", "grader", "timing", "retries",
            "interventions", "usage"}


def validate(record):
    missing = {key for key in REQUIRED if record.get(key) is None or (isinstance(record.get(key), str) and not record[key])}
    if missing:
        return {"status": "incomplete", "reason": "missing " + ", ".join(sorted(missing))}
    if not isinstance(record["commands"], list) or not isinstance(record["tool_calls"], list):
        return {"status": "incomplete", "reason": "malformed action evidence"}
    if not isinstance(record["grader"], dict) or not record["grader"].get("definition") or "verdict" not in record["grader"]:
        return {"status": "incomplete", "reason": "malformed decisive grader evidence"}
    if not isinstance(record["usage"], dict) or record["usage"].get("status") not in {"observed", "unavailable"}:
        return {"status": "incomplete", "reason": "malformed usage evidence"}
    if record["usage"]["status"] == "unavailable" and not record["usage"].get("reason"):
        return {"status": "incomplete", "reason": "missing usage limitation"}
    return {"status": "complete"}


def regrade(record, grader):
    """Invoke a retained task-local grader without a runtime or model."""
    result = validate(record)
    if result["status"] != "complete":
        return result
    verdict = grader(record["grader"]["definition"], record["final_tree"], record["commands"])
    return {"status": "complete", "verdict": verdict}

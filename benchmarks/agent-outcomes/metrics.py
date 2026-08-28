"""Deterministic trial metrics with explicit unavailable observations."""


def unavailable(reason):
    return {"status": "unavailable", "reason": reason}


def completion_claim(events):
    if not isinstance(events, list):
        return unavailable("missing completion-status evidence")
    return {"status": "observed", "value": any(bool(event.get("completion_claim")) for event in events if isinstance(event, dict))}


def command_validity(commands):
    if not isinstance(commands, list) or any(not isinstance(item, dict) or "valid" not in item for item in commands):
        return unavailable("missing task-local command validity")
    return {"status": "observed", "value": sum(not item["valid"] for item in commands)}


def derive(evidence):
    grader = evidence.get("grader", {})
    task = {"status": "observed", "value": grader.get("verdict") == "pass"} if grader.get("verdict") in {"pass", "fail"} else unavailable("missing objective grader verdict")
    claim = completion_claim(evidence.get("completion_status"))
    commands = command_validity(evidence.get("commands"))
    metrics = {"task_success": task, "completion_claim": claim, "invalid_commands": commands,
               "tool_calls": {"status": "observed", "value": len(evidence["tool_calls"])} if isinstance(evidence.get("tool_calls"), list) else unavailable("missing tool-call evidence"),
               "retries": {"status": "observed", "value": len(evidence["retries"])} if isinstance(evidence.get("retries"), list) else unavailable("missing retry evidence"),
               "elapsed_time": evidence.get("timing", {}).get("elapsed") if isinstance(evidence.get("timing"), dict) and evidence["timing"].get("elapsed") is not None else unavailable("elapsed time unavailable"),
               "usage": evidence.get("usage") if isinstance(evidence.get("usage"), dict) else unavailable("usage unavailable"),
               "interventions": {"status": "observed", "value": len(evidence["interventions"])} if isinstance(evidence.get("interventions"), list) else unavailable("missing intervention evidence")}
    metrics["violations"] = {"status": "observed", "value": len(evidence["violations"])} if isinstance(evidence.get("violations"), list) else unavailable("missing violation evidence")
    metrics["false_completion"] = {"status": "observed", "value": claim["value"] and not task["value"]} if claim["status"] == task["status"] == "observed" else unavailable("completion or task result unavailable")
    return metrics

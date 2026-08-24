"""Fail-closed retry, intervention, and missing-measurement policy."""


def decide(attempts, transient, intervention=False, allowed=False):
    if not attempts or not isinstance(attempts[-1], dict):
        raise ValueError("retained attempt required")
    if intervention and not allowed:
        raise ValueError("forbidden intervention")
    status = attempts[-1].get("status")
    # An agent result is evidence, never an infrastructure retry candidate.
    return "retry" if status in transient and status != "agent_failure" else "final"


def record_attempt(attempts, attempt):
    if not isinstance(attempt, dict) or not isinstance(attempt.get("id"), str) or not attempt["id"]:
        raise ValueError("attempt identity required")
    if any(item.get("id") == attempt["id"] for item in attempts):
        raise ValueError("duplicate attempt")
    return [*attempts, attempt]


def intervention_stratum(intervention, allowed=False):
    if intervention and not allowed:
        raise ValueError("forbidden intervention")
    return "intervened" if intervention else "unintervened"


def measurement(value, reason=None):
    if value is None:
        if not reason:
            raise ValueError("unavailable measurement reason required")
        return {"status": "unavailable", "reason": reason}
    return {"status": "observed", "value": value}

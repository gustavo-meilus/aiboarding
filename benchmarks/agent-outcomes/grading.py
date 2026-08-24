"""Objective-first normalized task-local grader records."""


def normalize(result):
    if not isinstance(result, dict) or result.get("provenance") not in {"computed", "inferred"}:
        raise ValueError("grader provenance required")
    if not isinstance(result.get("grader_id"), str) or not result["grader_id"]:
        raise ValueError("grader identity required")
    if result.get("status") in {"error", "timeout"}:
        return {**result, "verdict": "incomplete"}
    if result.get("verdict") not in {"pass", "fail"}:
        raise ValueError("grader verdict required")
    return result


def verdict(results):
    computed = [normalize(r) for r in results if r.get("provenance") == "computed"]
    if not computed or any(r["verdict"] == "incomplete" for r in computed):
        return "incomplete"
    if any(r["verdict"] == "fail" for r in computed):
        return "fail"
    return "pass"

#!/usr/bin/env python3
"""Deterministic contracts for the opt-in agent-outcome benchmark.

The live runner remains ``tests/live/verify_runtime.py`` and harmful-context
scenarios remain ``tests/fixtures/mutations/manifest.tsv``.  This module owns
only benchmark manifests and their immutable experiment identity.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
LIVE_RUNNER = ROOT / "tests" / "live" / "verify_runtime.py"
MUTATION_MANIFEST = ROOT / "tests" / "fixtures" / "mutations" / "manifest.tsv"
CONTROLLED = (
    "model", "runtime", "harness", "task", "fixture", "permissions",
    "tools", "budget", "timeout", "grader", "condition", "repetitions",
    "retry", "aggregation",
)
PROVENANCE = {"computed", "inferred"}


def canonical(value: Any) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode()


def fingerprint(identity: dict[str, Any]) -> str:
    return hashlib.sha256(canonical(identity)).hexdigest()


def fail(message: str) -> None:
    raise ValueError(message)


def object_named(value: Any, kind: str) -> dict[str, Any]:
    if not isinstance(value, dict):
        fail(f"{kind}: expected object")
    if value.get("schema_version") != 1 or not isinstance(value.get("id"), str) or not value["id"]:
        fail(f"{kind}: missing version or identity")
    return value


def mutation_ids() -> set[str]:
    if not MUTATION_MANIFEST.is_file():
        fail("mutation manifest unavailable")
    return {line.split("|", 1)[0] for line in MUTATION_MANIFEST.read_text(encoding="utf-8").splitlines()[1:] if line}


def validate(document: dict[str, Any]) -> None:
    contracts = object_named(document.get("contracts"), "contracts")
    if contracts["id"] != "agent-outcome-benchmark":
        fail("contracts: unexpected identity")
    tasks = [object_named(item, "task") for item in document.get("tasks", [])]
    conditions = [object_named(item, "condition") for item in document.get("conditions", [])]
    graders = [object_named(item, "grader") for item in document.get("graders", [])]
    experiment = object_named(document.get("experiment"), "experiment")
    aggregate = object_named(document.get("aggregate"), "aggregate")
    if not tasks or not conditions or not graders:
        fail("contracts: tasks, conditions, and graders are required")
    for task in tasks:
        for key in ("category", "fixture", "instruction", "expected_outcome", "permitted_environment", "grader_id"):
            if not isinstance(task.get(key), str) or not task[key]:
                fail(f"task {task['id']}: missing {key}")
    for condition in conditions:
        if not isinstance(condition.get("provenance"), dict):
            fail(f"condition {condition['id']}: missing provenance")
        scenario = condition["provenance"].get("mutation_scenario_id")
        if scenario is not None and scenario not in mutation_ids():
            fail(f"condition {condition['id']}: unknown mutation scenario")
    for grader in graders:
        if grader.get("provenance") not in PROVENANCE:
            fail(f"grader {grader['id']}: invalid provenance")
    identity = experiment.get("identity")
    allowed_controls = {frozenset(CONTROLLED), frozenset((*CONTROLLED, "codex"))}
    if not isinstance(identity, dict) or frozenset(identity) not in allowed_controls:
        fail("experiment: undeclared controlled variables")
    for name in ("model", "runtime"):
        observed = identity[name]
        if not isinstance(observed, dict) or not isinstance(observed.get("requested"), str) or not observed["requested"]:
            fail(f"experiment: {name} requested identity required")
        if observed.get("observed") is None and not isinstance(observed.get("limitation"), str):
            fail(f"experiment: {name} unavailable version requires limitation")
    if not experiment.get("frozen"):
        fail("experiment: must be frozen")
    expected = fingerprint(identity)
    if experiment.get("fingerprint") != expected:
        fail("experiment: mutable definition or fingerprint mismatch")
    trials = [object_named(item, "trial") for item in document.get("trials", [])]
    cells: set[tuple[str, str, int]] = set()
    for trial in trials:
        if trial.get("experiment_fingerprint") != expected:
            fail(f"trial {trial['id']}: experiment mismatch")
        cell = (str(trial.get("task_id")), str(trial.get("condition_id")), trial.get("repetition"))
        if not isinstance(cell[2], int) or cell in cells:
            fail("trials: duplicate or invalid cell")
        cells.add(cell)
        for evidence in trial.get("evidence", []):
            if not isinstance(evidence, dict) or evidence.get("provenance") not in PROVENANCE:
                fail(f"trial {trial['id']}: invalid evidence provenance")
    execution = document.get("execution")
    if execution is not None:
        if not isinstance(execution, dict) or execution.get("kind") not in {"diagnostic", "comparison"}:
            fail("execution: invalid kind")
        if execution.get("max_live_trials") != len(trials) or not trials:
            fail("execution: declared trial bound mismatch")
        diagnostic = execution.get("diagnostic_fingerprint")
        if execution["kind"] == "comparison" and (not isinstance(diagnostic, str) or not diagnostic):
            fail("execution: comparison diagnostic identity required")
        if execution["kind"] == "diagnostic" and diagnostic is not None:
            fail("execution: diagnostic cannot depend on diagnostic")
    if aggregate.get("experiment_fingerprint") != expected:
        fail("aggregate: experiment mismatch")
    if not LIVE_RUNNER.is_file():
        fail("shared live runtime unavailable")
    profile_version = document.get("profile_version", 0)
    if profile_version not in {0, 1, 2, 3}:
        fail("profile: unsupported version")
    required_conditions = {"none", "manual-minimal", "aiboarding-off", "aiboarding-lite", "aiboarding-full", "aiboarding-ultra", "stale", "contradictory", "truncate-9"}
    if profile_version in {1, 2}:
        categories = {task["category"] for task in tasks}
        if categories != {"command-discovery", "architecture-boundary", "domain-invariant", "known-failure-mode", "escalation", "nested-instructions"}:
            fail("profile: incomplete task categories")
        if not next((task for task in tasks if task["category"] == "nested-instructions" and task.get("nested_support_proof") is True), None):
            fail("profile: nested instruction support is unproven")
    if profile_version in {1, 2} or any("sha256" in item for item in [*tasks, *conditions, *graders]):
        for item in [*tasks, *conditions, *graders]:
            path, expected = item.get("path"), item.get("sha256")
            if not isinstance(path, str) or not isinstance(expected, str):
                fail("profile: artifact identity missing")
            artifact = Path(__file__).parent / path
            if not artifact.is_file() or hashlib.sha256(artifact.read_bytes()).hexdigest() != expected:
                fail("profile: artifact hash drift")
    if profile_version == 1:
        if len(trials) != len(tasks) * len(required_conditions) * 2:
            fail("profile: incomplete trial matrix")
        by_task = {task["id"]: set() for task in tasks}
        for condition in conditions:
            if condition.get("task_id") not in by_task or condition.get("condition_id") not in required_conditions:
                fail("profile: unknown condition")
            by_task[condition["task_id"]].add(condition["condition_id"])
        if any(found != required_conditions for found in by_task.values()):
            fail("profile: missing condition")
    elif profile_version == 2:
        smoke_conditions = {"none", "aiboarding-full"}
        if identity["repetitions"] != 1 or len(trials) != len(tasks) * len(smoke_conditions):
            fail("profile: incomplete smoke matrix")
        if {(condition["task_id"], condition["condition_id"]) for condition in conditions} != {(task["id"], condition) for task in tasks for condition in smoke_conditions}:
            fail("profile: invalid smoke condition matrix")
    elif profile_version == 3:
        codex = identity.get("codex")
        required = {"model": "gpt-5.6-luna", "reasoning_effort": "low", "web_search": "disabled", "ignore_user_config": True, "ephemeral": True, "jsonl": True, "sandbox": "workspace-write", "timeout_seconds": 60}
        if len(tasks) != len(conditions) != len(graders) != len(trials) != 1 or tasks[0]["id"] != "command-discovery" or conditions[0]["id"] != "command-discovery:aiboarding-full" or identity["repetitions"] != 1 or codex != required:
            fail("profile: invalid one-cell Codex diagnostic")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--fingerprint", action="store_true")
    args = parser.parse_args()
    try:
        document = json.loads(args.manifest.read_text(encoding="utf-8"))
        validate(document)
    except (OSError, json.JSONDecodeError, ValueError) as error:
        print(f"benchmark contract: {error}", file=sys.stderr)
        return 2
    if args.fingerprint:
        print(document["experiment"]["fingerprint"])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

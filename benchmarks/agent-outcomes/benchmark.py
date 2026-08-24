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
    if not isinstance(identity, dict) or set(identity) != set(CONTROLLED):
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
    if aggregate.get("experiment_fingerprint") != expected:
        fail("aggregate: experiment mismatch")
    if not LIVE_RUNNER.is_file():
        fail("shared live runtime unavailable")


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

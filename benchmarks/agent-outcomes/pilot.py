#!/usr/bin/env python3
"""Run the small, explicit Codex pilot; normal tests never invoke this."""
from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import shutil
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent


def load(name: str):
    spec = importlib.util.spec_from_file_location(name, HERE / f"{name}.py")
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    return module


runner = load("runner")
live_runtime = runner.live_runtime


def tree_hash(root: Path) -> str:
    digest = hashlib.sha256()
    for path in sorted(root.rglob("*")):
        if path.is_file() and ".git" not in path.parts:
            digest.update(path.relative_to(root).as_posix().encode() + b"\0" + path.read_bytes())
    return digest.hexdigest()


def sanitized_events(raw: str, scratch: Path) -> list[dict]:
    """Retain only command/tool facts; prose can contain unrelated local context."""
    events = []
    for line in live_runtime.redact(raw).splitlines():
        try: event = json.loads(line)
        except json.JSONDecodeError: continue
        item = event.get("item") if isinstance(event, dict) else None
        if isinstance(item, dict) and item.get("type") == "command_execution":
            command = item.get("command")
            if isinstance(command, str):
                command = "sha256:" + hashlib.sha256(command.encode()).hexdigest()
            events.append({"type": event.get("type"), "item": {"id": item.get("id"), "type": "command_execution", "command": command}})
        elif isinstance(item, dict) and item.get("type") == "file_change":
            events.append({"type": event.get("type"), "item": {"id": item.get("id"), "type": "file_change"}})
    return events


def profile_cells(document: dict) -> list[dict]:
    """Return the declared profile plan, rejecting derived-matrix drift."""
    planner = load("planner")
    task_ids = [task["id"] for task in document["tasks"]]
    condition_ids = sorted({condition["condition_id"] for condition in document["conditions"]})
    cells = planner.plan(task_ids, condition_ids, document["experiment"]["identity"]["repetitions"], document["experiment"]["ordering_seed"])
    declared = {(trial["task_id"], trial["condition_id"], trial["repetition"]) for trial in document["trials"]}
    if {(cell["task_id"], cell["condition_id"], cell["repetition"]) for cell in cells} != declared:
        raise ValueError("profile trial matrix drift")
    return cells


def run_profile(document: dict, adapter) -> list:
    """Apply only profile-declared packs and frozen bundles through the runner."""
    task_paths = {task["id"]: HERE / Path(task["path"]).parent for task in document["tasks"]}
    condition_paths = {(item["task_id"], item["condition_id"]): HERE / item["path"] for item in document["conditions"]}
    if any(json.loads(path.read_text(encoding="utf-8")).get("schema_version") != 2 for path in condition_paths.values()):
        raise ValueError("profile execution requires frozen condition bundles")
    return [runner.run_pack(task_paths[cell["task_id"]], condition_paths[cell["task_id"], cell["condition_id"]], document["experiment"]["fingerprint"], adapter, document["experiment"]["identity"]) for cell in profile_cells(document)]


def retained_records(document: dict, output: Path) -> dict:
    evidence, metrics = load("evidence"), load("metrics")
    found = {}
    expected = hashlib.sha256(json.dumps(document["experiment"]["identity"], sort_keys=True, separators=(",", ":")).encode()).hexdigest()
    for trial_path in output.rglob("trial.json"):
        record = json.loads(trial_path.read_text(encoding="utf-8"))
        key = record.get("task_id"), record.get("condition_id"), record.get("repetition")
        grader = HERE / "tasks" / str(record.get("task_id")) / "grader.py"
        verdict = {"status": "incomplete", "reason": "controlled-variable drift"} if record.get("identity", {}).get("controls_fingerprint") != expected else evidence.regrade_snapshot(record, grader, trial_path.parent / "final-tree")
        found[key] = {**record, "evidence_status": verdict["status"], "objective_verdict": verdict.get("verdict"), "metrics": metrics.derive(record) if verdict["status"] == "complete" else {}}
    return found


def diagnostic_gate(document: dict, records: dict) -> dict:
    cells = profile_cells(document)
    incomplete = []
    for cell in cells:
        key = cell["task_id"], cell["condition_id"], cell["repetition"]
        if not records.get(key) or records[key]["evidence_status"] != "complete":
            incomplete.append(": ".join(map(str, key)))
    return {"kind": "diagnostic", "unpublished": True, "profile": document["experiment"]["fingerprint"], "planned": len(cells), "complete": len(cells) - len(incomplete), "incomplete": incomplete, "viable": not incomplete}


def expansion_allowed(document: dict, gate_path: Path | None) -> None:
    execution = document.get("execution", {})
    if execution.get("kind") != "comparison":
        return
    if gate_path is None:
        raise ValueError("comparison requires --expand-from diagnostic-gate.json")
    gate = json.loads(gate_path.read_text(encoding="utf-8"))
    if not gate.get("viable") or gate.get("profile") != execution["diagnostic_fingerprint"]:
        raise ValueError("comparison requires viable matching diagnostic")


def execute(pack: Path, condition: Path, fingerprint: str, output: Path, timeout: int, model: str | None, repetition: int, controls: dict | None = None) -> dict:
    task = json.loads((pack / "task.json").read_text(encoding="utf-8"))
    prompt = (pack / "agent-instructions.md").read_text(encoding="utf-8") + "\n\n" + task["instruction"]

    def adapter(scratch: Path, _instruction: str, identity: dict) -> dict:
        codex = (controls or {}).get("codex", {})
        timeout_seconds = codex.get("timeout_seconds", timeout)
        selected_model = codex.get("model", model)
        command = ["codex", "exec"]
        if codex.get("jsonl", True): command += ["--json"]
        if codex.get("ephemeral", True): command += ["--ephemeral"]
        if codex.get("ignore_user_config"): command += ["--ignore-user-config"]
        command += ["--sandbox", codex.get("sandbox", "danger-full-access"), "-C", str(scratch)]
        if selected_model: command += ["--model", selected_model]
        if codex.get("reasoning_effort"): command += ["-c", f'model_reasoning_effort="{codex["reasoning_effort"]}"']
        started = time.time()
        try:
            process = subprocess.run(command + [prompt], text=True, encoding="utf-8", errors="replace", capture_output=True, timeout=timeout_seconds)
            stdout, stderr, timed_out = process.stdout, process.stderr, False
        except subprocess.TimeoutExpired as error:
            stdout, stderr, process, timed_out = error.stdout or "", error.stderr or "", None, True
        events = sanitized_events(stdout or "", scratch)
        stdout, stderr = "\n".join(json.dumps(event, sort_keys=True) for event in events) + "\n", live_runtime.redact(stderr or "")
        completed = [event["item"] for event in events if event.get("type") == "item.completed" and isinstance(event.get("item"), dict)]
        commands = [{"command": item["command"], "valid": True} for item in completed if item.get("type") == "command_execution" and isinstance(item.get("command"), str)]
        tool_calls = [{"type": item.get("type"), "id": item.get("id")} for item in completed if item.get("type") in {"command_execution", "file_change"}]
        graded = subprocess.run(["python3", str(pack / "grader.py"), str(scratch)], text=True, capture_output=True)
        verdict = "pass" if graded.returncode == 0 else "fail"
        trial = {
            "task_id": task["id"], "condition_id": json.loads(condition.read_text(encoding="utf-8"))["id"],
            "experiment_fingerprint": fingerprint, "repetition": repetition, "final_tree": tree_hash(scratch), "commands": commands, "tool_calls": tool_calls,
            "completion": stdout, "completion_status": events,
            "grader": {"definition": (pack / "grader.py").read_text(encoding="utf-8"), "verdict": verdict},
            "timing": {"elapsed": time.time() - started, "timeout": timeout_seconds, "timed_out": timed_out},
            "retries": [], "interventions": [], "usage": {"status": "unavailable", "reason": "Codex event stream exposes no stable usage metric"},
            "runtime": {"requested": "codex", "observed": subprocess.run(["codex", "--version"], text=True, capture_output=True).stdout.strip() or None},
            "identity": identity,
            "exit": None if process is None else process.returncode, "stderr": stderr,
        }
        trial_dir = output / task["id"] / trial["condition_id"] / identity["session"]
        trial_dir.mkdir(parents=True, exist_ok=True)
        snapshot = trial_dir / "final-tree"
        snapshot.mkdir()
        missing = []
        for name in task.get("retained_files", []):
            source = scratch / name
            if not source.is_file() or Path(name).is_absolute() or ".." in Path(name).parts:
                missing.append(name)
                continue
            target = snapshot / name
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
        trial["final_tree"] = tree_hash(snapshot)
        trial["grader"]["snapshot"] = "final-tree"
        trial["retention"] = {"status": "incomplete", "reason": "missing retained task evidence: " + ", ".join(missing)} if missing else {"status": "complete"}
        (trial_dir / "events.jsonl").write_text(stdout, encoding="utf-8")
        (trial_dir / "trial.json").write_text(json.dumps(trial, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        return trial

    _, trial = runner.run_pack(pack, condition, fingerprint, adapter, controls)
    return trial


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--timeout", type=int)
    parser.add_argument("--model")
    parser.add_argument("--fingerprint", default=hashlib.sha256(b"aiboarding-agent-outcomes-pilot-v1").hexdigest())
    parser.add_argument("--repetitions", type=int, default=1)
    parser.add_argument("--seed", default="pilot-v1")
    parser.add_argument("--reportable", action="store_true")
    parser.add_argument("--profile", type=Path)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--offline", type=Path, metavar="RESULTS")
    parser.add_argument("--expand-from", type=Path, metavar="DIAGNOSTIC_GATE")
    args = parser.parse_args()
    if args.repetitions < 1: raise ValueError("repetitions must be positive")
    planner = load("planner")
    if args.profile:
        benchmark = load("benchmark")
        document = json.loads(args.profile.read_text(encoding="utf-8")); benchmark.validate(document)
        cells = profile_cells(document)
        expansion_allowed(document, args.expand_from)
        seed = document["experiment"]["ordering_seed"]
        if any(json.loads((HERE / item["path"]).read_text(encoding="utf-8")).get("schema_version") != 2 for item in document["conditions"]):
            raise ValueError("profile execution requires frozen condition bundles")
        if args.dry_run:
            print(json.dumps(cells, indent=2)); return 0
        if args.offline:
            evidence, metrics, aggregate, report, package = (load(name) for name in ("evidence", "metrics", "aggregate", "report", "package"))
            retained = retained_records(document, args.offline)
            if document.get("execution", {}).get("kind") == "diagnostic":
                gate = diagnostic_gate(document, retained)
                (args.output / "diagnostic-gate.json").write_text(json.dumps(gate, indent=2, sort_keys=True) + "\n", encoding="utf-8")
                return 0 if gate["viable"] else 1
            rows = []
            for cell in cells:
                record = retained.get((cell["task_id"], cell["condition_id"], cell["repetition"]))
                rows.append({"task": cell["task_id"], "condition": cell["condition_id"], "success": "incomplete" if not record or record["evidence_status"] != "complete" else record["objective_verdict"], "evidence": "complete" if record and record["evidence_status"] == "complete" else "incomplete"})
            staged = args.output / ".staging"
            staged.mkdir(parents=True, exist_ok=True)
            summary = {**aggregate.summarize(rows), "metrics": aggregate.metric_summaries(retained.values())}
            (staged / "aggregate.json").write_text(json.dumps({"profile": document["experiment"]["fingerprint"], "rows": rows, "summary": summary}, indent=2, sort_keys=True) + "\n", encoding="utf-8")
            (staged / "report.md").write_text(report.render(rows, summary), encoding="utf-8")
            inventory = {"profile": document["experiment"]["fingerprint"], "planned": len(cells), "complete": summary["complete"], "incomplete": summary["incomplete"]}
            (staged / "inventory.json").write_text(json.dumps(inventory, indent=2, sort_keys=True) + "\n", encoding="utf-8")
            package.package(staged, ["aggregate.json", "report.md"], staged / "evidence.zip", complete=summary["incomplete"] == 0)
            for name in ("aggregate.json", "report.md", "inventory.json", "evidence.zip"):
                (args.output / name).write_bytes((staged / name).read_bytes())
            return 0
        task_paths = {task["id"]: HERE / Path(task["path"]).parent for task in document["tasks"]}
        condition_paths = {(item["task_id"], item["condition_id"]): HERE / item["path"] for item in document["conditions"]}
        results = [execute(task_paths[cell["task_id"]], condition_paths[cell["task_id"], cell["condition_id"]], document["experiment"]["fingerprint"], args.output, args.timeout or 60, args.model, cell["repetition"], document["experiment"]["identity"]) for cell in cells]
        args.fingerprint, args.seed = document["experiment"]["fingerprint"], seed
    else:
        pack = HERE / "tasks" / "command-discovery"
        paths = {"none": "none.json", "aiboarding-off": "aiboarding-off.json"}
        results = [execute(pack, HERE.parent.parent / "tests" / "fixtures" / "agent-outcomes" / "conditions" / paths[cell["condition_id"]], args.fingerprint, args.output, args.timeout or 60, args.model, cell["repetition"]) for cell in planner.plan(["command-discovery"], paths, args.repetitions, args.seed)]
    diagnostic = document.get("execution", {}).get("kind") == "diagnostic" if args.profile else False
    gate = diagnostic_gate(document, retained_records(document, args.output)) if diagnostic else None
    if gate:
        (args.output / "diagnostic-gate.json").write_text(json.dumps(gate, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    (args.output / "pilot-summary.json").write_text(json.dumps({"label": "diagnostic" if diagnostic else "reportable" if args.reportable else "pilot", "reportable": args.reportable and not diagnostic, "fingerprint": args.fingerprint, "ordering_seed": args.seed, "results": results}, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    if gate:
        return 0 if gate["viable"] else 1
    return 0 if all(item["grader"]["verdict"] == "pass" for item in results) else 1


if __name__ == "__main__":
    raise SystemExit(main())

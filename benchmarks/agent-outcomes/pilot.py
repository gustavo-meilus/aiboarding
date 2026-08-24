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


def execute(pack: Path, condition: Path, fingerprint: str, output: Path, timeout: int, model: str | None, repetition: int) -> dict:
    task = json.loads((pack / "task.json").read_text(encoding="utf-8"))
    prompt = (pack / "agent-instructions.md").read_text(encoding="utf-8") + "\n\n" + task["instruction"]

    def adapter(scratch: Path, _instruction: str, identity: dict) -> dict:
        command = ["codex", "exec", "--json", "--ephemeral", "--sandbox", "danger-full-access", "--dangerously-bypass-hook-trust", "-C", str(scratch)]
        if model: command += ["--model", model]
        started = time.time()
        try:
            process = subprocess.run(command + [prompt], text=True, capture_output=True, timeout=timeout)
            stdout, stderr, timed_out = process.stdout, process.stderr, False
        except subprocess.TimeoutExpired as error:
            stdout, stderr, process, timed_out = error.stdout or "", error.stderr or "", None, True
        stdout, stderr = live_runtime.redact(stdout), live_runtime.redact(stderr)
        events = []
        for line in stdout.splitlines():
            try: events.append(json.loads(line))
            except json.JSONDecodeError: pass
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
            "timing": {"elapsed": time.time() - started, "timeout": timeout, "timed_out": timed_out},
            "retries": [], "interventions": [], "usage": {"status": "unavailable", "reason": "Codex event stream exposes no stable usage metric"},
            "runtime": {"requested": "codex", "observed": subprocess.run(["codex", "--version"], text=True, capture_output=True).stdout.strip() or None},
            "exit": None if process is None else process.returncode, "stderr": stderr,
        }
        trial_dir = output / task["id"] / trial["condition_id"] / identity["session"]
        trial_dir.mkdir(parents=True, exist_ok=True)
        snapshot = trial_dir / "final-tree"
        snapshot.mkdir()
        for name in task.get("retained_files", []):
            source = scratch / name
            if not source.is_file() or Path(name).is_absolute() or ".." in Path(name).parts:
                raise ValueError("missing or unsafe retained task evidence")
            target = snapshot / name
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
        trial["final_tree"] = tree_hash(snapshot)
        trial["grader"]["snapshot"] = "final-tree"
        (trial_dir / "events.jsonl").write_text(stdout, encoding="utf-8")
        (trial_dir / "trial.json").write_text(json.dumps(trial, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        return trial

    _, trial = runner.run_pack(pack, condition, fingerprint, adapter)
    return trial


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--timeout", type=int, default=60)
    parser.add_argument("--model")
    parser.add_argument("--fingerprint", default=hashlib.sha256(b"aiboarding-agent-outcomes-pilot-v1").hexdigest())
    parser.add_argument("--repetitions", type=int, default=1)
    parser.add_argument("--seed", default="pilot-v1")
    parser.add_argument("--reportable", action="store_true")
    args = parser.parse_args()
    if args.repetitions < 1: raise ValueError("repetitions must be positive")
    pack = HERE / "tasks" / "command-discovery"
    planner = load("planner")
    paths = {"none": "none.json", "aiboarding-off": "aiboarding-off.json"}
    results = [execute(pack, HERE.parent.parent / "tests" / "fixtures" / "agent-outcomes" / "conditions" / paths[cell["condition_id"]], args.fingerprint, args.output, args.timeout, args.model, cell["repetition"]) for cell in planner.plan(["command-discovery"], paths, args.repetitions, args.seed)]
    (args.output / "pilot-summary.json").write_text(json.dumps({"label": "reportable" if args.reportable else "pilot", "reportable": args.reportable, "fingerprint": args.fingerprint, "ordering_seed": args.seed, "results": results}, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return 0 if all(item["grader"]["verdict"] == "pass" for item in results) else 1


if __name__ == "__main__":
    raise SystemExit(main())

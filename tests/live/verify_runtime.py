#!/usr/bin/env python3
"""Opt-in, isolated verification of native agent onboarding loading.

The normal shell suite only runs this command against fake executables.  A live
run is explicit (`--live`) and retains only sanitized, case-local evidence.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import secrets
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FORBIDDEN = ("tool", "command", "mcp", "web", "file")


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write_json(path: Path, value: object) -> None:
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def redact(value: str) -> str:
    """Keep raw protocol evidence useful without retaining bearer/API secrets."""
    import re
    return re.sub(r"(?i)(bearer\\s+|(?:api[_-]?key|token|secret)[=:]\\s*)[^\\s\"']+", r"\\1[REDACTED]", value)


def source_state() -> dict[str, object]:
    def git(*args: str) -> str:
        result = subprocess.run(["git", "-C", str(ROOT), *args], text=True, capture_output=True)
        return result.stdout.strip() if result.returncode == 0 else "unavailable"
    return {"commit": git("rev-parse", "HEAD"), "dirty": bool(git("status", "--porcelain"))}


def executable_command(executable: str) -> list[str]:
    if Path(executable).is_file() and Path(executable).suffix.lower() not in {".exe", ".cmd", ".bat"}:
        shell = Path(sh).with_name("bash.exe") if os.name == "nt" and (sh := shutil.which("sh")) else Path("bash")
        return [shell.as_posix(), Path(executable).as_posix()]
    return [executable]


def command_for(runtime: str, executable: str) -> list[str]:
    runner = executable_command(executable)
    if runtime == "claude":
        return [*runner, "--print", "--verbose", "--output-format", "stream-json", "--no-session-persistence", "--setting-sources", "project", "--tools", "", "--", "What is the onboarding token?"]
    return [*runner, "exec", "--json", "--ephemeral", "--sandbox", "read-only", "--dangerously-bypass-hook-trust", "Return exactly the onboarding token. If none is loaded, return NONE. Do not use tools or explain."]


def parse_events(runtime: str, raw: str) -> tuple[list[object], str | None]:
    events: list[object] = []
    for line in raw.splitlines():
        if not line.strip():
            continue
        try:
            events.append(json.loads(line))
        except json.JSONDecodeError:
            return events, "malformed JSONL"
    if not events:
        return events, "missing structured evidence"
    return events, None


def event_text(events: list[object]) -> str:
    return "\n".join(json.dumps(event, sort_keys=True) for event in events)


def has_terminal_error(events: list[object]) -> bool:
    return any(isinstance(event, dict) and str(event.get("type", "")).lower() in {"error", "failed"} for event in events)


def probe(runtime: str, executable: str) -> dict[str, object]:
    """Probe executable/version only. Authentication is never tested with a turn."""
    command = [*executable_command(executable), "--version"]
    try:
        result = subprocess.run(command, text=True, capture_output=True, timeout=10)
    except (FileNotFoundError, subprocess.TimeoutExpired) as error:
        return {"runtime": runtime, "executable": executable, "status": "fail", "reason": str(error)}
    version = (result.stdout or result.stderr).strip()
    if result.returncode or not version:
        return {"runtime": runtime, "executable": executable, "status": "fail", "reason": version or "version probe failed", "exit": result.returncode}
    return {"runtime": runtime, "executable": executable, "status": "pass", "version": version, "non_interactive": True, "structured_events": True, "authentication": "not invoked"}


def fresh_repository(prefix: str, fixture: Path | None = None) -> Path:
    """Create the shared isolated Git fixture used by live and benchmark cases."""
    scratch = Path(tempfile.mkdtemp(prefix=prefix))
    if fixture:
        shutil.copytree(fixture, scratch, dirs_exist_ok=True)
    subprocess.run(["git", "init", "-q", str(scratch)], check=True, capture_output=True)
    return scratch


def run_case(runtime: str, name: str, executable: str, runtime_version: str, evidence: Path, timeout: int, collect_hooks: bool) -> dict[str, object]:
    case_dir = evidence / runtime / name
    case_dir.mkdir(parents=True, exist_ok=True)
    scratch = fresh_repository(f"aiboarding-{runtime}-{name}-")
    canary = "AIBOARDING-CANARY-" + secrets.token_hex(16)
    if name == "positive":
        (scratch / "AGENTS.md").write_text(canary + "\n", encoding="utf-8")
        if runtime == "claude":
            (scratch / "CLAUDE.md").write_text("@AGENTS.md\n", encoding="utf-8")
    collector = case_dir / "collector.jsonl"
    scratch_collector = scratch / "collector.jsonl"
    if collect_hooks and runtime == "codex":
        hook_dir = scratch / ".codex"
        hook_dir.mkdir()
        collector_script = scratch / "collector.sh"
        shutil.copy2(ROOT / "tests" / "live" / "collector.sh", collector_script)
        collector_script.chmod(0o755)
        command = f'bash "{collector_script}"'
        write_json(hook_dir / "hooks.json", {"hooks": {"SessionStart": [{"hooks": [{"type": "command", "command": command, "commandWindows": command, "timeout": 5}]}]}})
    case = {"runtime": runtime, "case": name, "canary_sha256": hashlib.sha256(canary.encode()).hexdigest(), "source": source_state(), "fixture": "generated", "command": command_for(runtime, executable), "started_at": time.time()}
    write_json(case_dir / "case.json", case)
    # Keep the caller's authenticated runtime environment for execution, but
    # never serialize it into case evidence.
    environment = {**os.environ, "AIBOARDING_LIVE_CASE": name, "AIBOARDING_LIVE_CANARY": canary, "AIBOARDING_COLLECTOR_FILE": str(scratch_collector)}
    try:
        result = subprocess.run(case["command"], cwd=scratch, text=True, capture_output=True, timeout=timeout, env=environment)
        stdout, stderr, timed_out = result.stdout, result.stderr, False
    except subprocess.TimeoutExpired as error:
        stdout, stderr, timed_out, result = error.stdout or "", error.stderr or "", True, None
    stdout, stderr = redact(stdout), redact(stderr)
    (case_dir / "stdout.jsonl").write_text(stdout, encoding="utf-8")
    (case_dir / "stderr.txt").write_text(stderr, encoding="utf-8")
    events, parse_error = parse_events(runtime, stdout)
    write_json(case_dir / "events.json", events)
    text = event_text(events)
    forbidden = any(word in text.lower() for word in FORBIDDEN)
    expected = canary in text if name == "positive" else canary not in text
    verdict = "pass"
    reason = ""
    if timed_out:
        verdict, reason = "fail", "timeout"
    elif result is None or result.returncode:
        verdict, reason = "fail", "non-zero runtime exit"
    elif parse_error:
        verdict, reason = "fail", parse_error
    elif has_terminal_error(events):
        verdict, reason = "fail", "terminal runtime error"
    elif forbidden:
        verdict, reason = "fail", "forbidden tool activity"
    elif not expected:
        verdict, reason = "fail", "canary control mismatch"
    if scratch_collector.exists():
        shutil.copy2(scratch_collector, collector)
    if collect_hooks and verdict == "pass" and not collector.exists():
        verdict, reason = "fail", "missing SessionStart collector evidence"
    evidence_files = ["case.json", "stdout.jsonl", "stderr.txt", "events.json"]
    if collector.exists():
        evidence_files.append("collector.jsonl")
    record = {**case, "runtime_version": runtime_version, "ended_at": time.time(), "verdict": verdict, "reason": reason, "exit": None if result is None else result.returncode,
              "evidence": {name: digest(case_dir / name) for name in evidence_files}}
    write_json(case_dir / "result.json", record)
    shutil.rmtree(scratch)
    return record


def import_lifecycle_evidence(project: Path, summary: dict[str, object]) -> str | None:
    writer = project / ".aiboarding" / "tools" / "write-evidence"
    if not writer.is_file():
        return "writer unavailable"
    source = summary["source"]
    if not isinstance(source, dict) or not isinstance(source.get("commit"), str):
        return "summary source unavailable"
    identity = "local-repository"
    remote = subprocess.run(["git", "-C", str(ROOT), "remote", "get-url", "origin"], text=True, capture_output=True)
    if remote.returncode == 0:
        identity = remote.stdout.strip().removeprefix("https://").removeprefix("git@").removesuffix(".git").replace(":", "/")
    for item in summary["results"]:
        if not isinstance(item, dict):
            return "malformed result"
        runtime = str(item.get("runtime", "unavailable"))
        verdict = str(item.get("verdict", "incomplete"))
        version = str(item.get("runtime_version", item.get("capability", {}).get("version", "unavailable")))
        protocol = str(item.get("case", "summary"))
        details = {"runtime": runtime, "version": version, "protocol": protocol, "verdict": verdict,
                   "evidence": sorted(str(v) for v in item.get("evidence", {}).values())}
        record = {"schema_version": 1, "record_id": f"live:{source['commit']}:{runtime}:{protocol}:{verdict}",
                  "type": "live-runtime-verification", "outcome": verdict if verdict in {"pass", "fail", "degraded", "unavailable"} else "incomplete",
                  "repository": {"identity": identity, "head": source["commit"]}, "details": details}
        with tempfile.NamedTemporaryFile("w", encoding="utf-8", suffix=".json", delete=False) as handle:
            json.dump(record, handle, sort_keys=True)
        try:
            result = subprocess.run([*executable_command(str(writer)), "--project", str(project), "--record", handle.name], text=True, capture_output=True)
        finally:
            Path(handle.name).unlink(missing_ok=True)
        if result.returncode:
            return "writer failed"
    return None


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runtime", choices=("claude", "codex", "all"), default="all")
    parser.add_argument("--case", choices=("positive", "negative", "all"), default="all")
    parser.add_argument("--live", action="store_true", help="required for non-fake execution")
    parser.add_argument("--claude", default=os.environ.get("AIBOARDING_CLAUDE", "claude"))
    parser.add_argument("--codex", default=os.environ.get("AIBOARDING_CODEX", "codex"))
    parser.add_argument("--evidence-dir", type=Path, default=ROOT / ".aiboarding" / "live-evidence")
    parser.add_argument("--timeout", type=int, default=20)
    parser.add_argument("--strict", action="store_true")
    parser.add_argument("--collect-hooks", action="store_true", help="require scratch SessionStart collector evidence (Codex only)")
    parser.add_argument("--lifecycle-evidence-project", type=Path, help="optionally import compact lifecycle records")
    args = parser.parse_args()
    if not args.live:
        print("refusing live runtime invocation without --live", file=sys.stderr)
        return 2
    args.evidence_dir.mkdir(parents=True, exist_ok=True)
    runtimes = ("claude", "codex") if args.runtime == "all" else (args.runtime,)
    results: list[dict[str, object]] = []
    for runtime in runtimes:
        executable = getattr(args, runtime)
        capability = probe(runtime, executable)
        if capability["status"] != "pass":
            results.append({"runtime": runtime, "case": "capability", "verdict": "degraded", "reason": capability["reason"], "capability": capability})
            continue
        for name in (("positive", "negative") if args.case == "all" else (args.case,)):
            results.append(run_case(runtime, name, executable, str(capability["version"]), args.evidence_dir, args.timeout, args.collect_hooks))
    verdicts = {result["verdict"] for result in results}
    exit_code = 1 if "fail" in verdicts or (args.strict and "degraded" in verdicts) else 2 if "degraded" in verdicts else 0
    summary = {"source": source_state(), "results": results, "exit": exit_code}
    if args.lifecycle_evidence_project:
        failure = import_lifecycle_evidence(args.lifecycle_evidence_project, summary)
        if failure:
            summary["evidence_recording"] = "degraded"
            print(f"lifecycle evidence recording degraded: {failure}", file=sys.stderr)
    write_json(args.evidence_dir / "summary.json", summary)
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())

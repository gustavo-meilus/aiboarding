#!/usr/bin/env python3
"""Thin benchmark setup over the shared live-runtime isolation primitive."""
from __future__ import annotations
import hashlib, importlib.util, json, secrets, shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("live_runtime", ROOT / "tests" / "live" / "verify_runtime.py")
live_runtime = importlib.util.module_from_spec(spec); spec.loader.exec_module(live_runtime)

def prepare(fixture: Path, bundle: dict[str, str], fingerprint: str) -> tuple[Path, dict[str, str]]:
    if len(fingerprint) != 64: raise ValueError("frozen experiment fingerprint required")
    scratch = live_runtime.fresh_repository("aiboarding-benchmark-", fixture)
    for name, text in bundle.items():
        path = scratch / name; path.parent.mkdir(parents=True, exist_ok=True); path.write_text(text, encoding="utf-8")
    return scratch, {"experiment_fingerprint": fingerprint, "repository": hashlib.sha256(str(scratch).encode()).hexdigest(), "session": secrets.token_hex(16)}


def run_trial(fixture: Path, bundle: dict[str, str], fingerprint: str, adapter):
    """Run one adapter callback in a disposable shared-live-harness fixture."""
    scratch, identity = prepare(fixture, bundle, fingerprint)
    try:
        return identity, adapter(scratch, identity)
    finally:
        shutil.rmtree(scratch, ignore_errors=True)


def run_pack(pack: Path, condition: Path, fingerprint: str, adapter):
    """Run one sealed task pack with one already-frozen condition."""
    task = json.loads((pack / "task.json").read_text(encoding="utf-8"))
    bundle = json.loads(condition.read_text(encoding="utf-8"))
    if bundle.get("id") not in task.get("applicable_conditions", []):
        raise ValueError("condition is not applicable to task")
    return run_trial(
        pack / "fixture", bundle.get("files", {}), fingerprint,
        lambda scratch, identity: adapter(scratch, task["instruction"], identity),
    )

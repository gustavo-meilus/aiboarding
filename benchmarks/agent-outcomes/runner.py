#!/usr/bin/env python3
"""Thin benchmark setup over the shared live-runtime isolation primitive."""
from __future__ import annotations
import hashlib, importlib.util, json, secrets, shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("live_runtime", ROOT / "tests" / "live" / "verify_runtime.py")
live_runtime = importlib.util.module_from_spec(spec); spec.loader.exec_module(live_runtime)
conditions_spec = importlib.util.spec_from_file_location("conditions", Path(__file__).with_name("conditions.py"))
conditions = importlib.util.module_from_spec(conditions_spec); conditions_spec.loader.exec_module(conditions)

def prepare(fixture: Path, bundle: dict[str, str], fingerprint: str, controls: dict | None = None) -> tuple[Path, dict[str, str]]:
    if len(fingerprint) != 64: raise ValueError("frozen experiment fingerprint required")
    scratch = live_runtime.fresh_repository("aiboarding-benchmark-", fixture)
    for name, text in bundle.items():
        path = scratch / name; path.parent.mkdir(parents=True, exist_ok=True); path.write_text(text, encoding="utf-8")
    controlled = controls or {}
    return scratch, {"experiment_fingerprint": fingerprint, "repository": hashlib.sha256(str(scratch).encode()).hexdigest(), "session": secrets.token_hex(16), "controls": controlled, "controls_fingerprint": hashlib.sha256(json.dumps(controlled, sort_keys=True, separators=(",", ":")).encode()).hexdigest()}


def run_trial(fixture: Path, bundle: dict[str, str], fingerprint: str, adapter, controls: dict | None = None):
    """Run one adapter callback in a disposable shared-live-harness fixture."""
    scratch, identity = prepare(fixture, bundle, fingerprint, controls)
    try:
        return identity, adapter(scratch, identity)
    finally:
        shutil.rmtree(scratch, ignore_errors=True)


def run_pack(pack: Path, condition: Path, fingerprint: str, adapter, controls: dict | None = None):
    """Run one sealed task pack with one already-frozen condition."""
    task = json.loads((pack / "task.json").read_text(encoding="utf-8"))
    bundle = json.loads(condition.read_text(encoding="utf-8"))
    if bundle.get("id") not in task.get("applicable_conditions", []):
        raise ValueError("condition is not applicable to task")
    return run_trial(
        pack / "fixture", conditions.contents(bundle), fingerprint,
        lambda scratch, identity: adapter(scratch, task["instruction"], identity), controls,
    )

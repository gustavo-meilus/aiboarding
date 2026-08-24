#!/usr/bin/env python3
"""Opt-in no-model marketplace controls in disposable runtime homes."""
from __future__ import annotations

import argparse
import os
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def invoke(command: list[str], environment: dict[str, str]) -> None:
    result = subprocess.run(command, text=True, env=environment)
    if result.returncode:
        raise RuntimeError("command failed: " + " ".join(command))


def verify(runtime: str) -> None:
    with tempfile.TemporaryDirectory(prefix=f"aiboarding-{runtime}-marketplace-", ignore_cleanup_errors=True) as home:
        environment = os.environ | {"HOME": home, "USERPROFILE": home, "APPDATA": home, "LOCALAPPDATA": home}
        if runtime == "claude":
            invoke(["claude", "plugin", "marketplace", "add", str(ROOT)], environment)
            invoke(["claude", "plugin", "install", "aiboarding@aiboarding", "--scope", "user", "--yes"], environment)
            invalid = ["claude", "plugin", "install", "does-not-exist@aiboarding", "--scope", "user", "--yes"]
        else:
            environment["CODEX_HOME"] = home
            invoke(["codex", "plugin", "marketplace", "add", str(ROOT), "--json"], environment)
            invoke(["codex", "plugin", "add", "aiboarding", "--marketplace", "aiboarding", "--json"], environment)
            invalid = ["codex", "plugin", "add", "does-not-exist", "--marketplace", "aiboarding", "--json"]
        if subprocess.run(invalid, env=environment).returncode == 0:
            raise RuntimeError(f"invalid {runtime} plugin unexpectedly installed")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("runtime", choices=("claude", "codex", "all"), default="all", nargs="?")
    runtime = parser.parse_args().runtime
    for selected in (("claude", "codex") if runtime == "all" else (runtime,)):
        verify(selected)


if __name__ == "__main__":
    main()

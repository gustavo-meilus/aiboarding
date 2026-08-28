"""Allowlisted, hashed standard-library evidence packaging."""
from __future__ import annotations
import hashlib
import json
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

FORBIDDEN = {".ssh", ".aws", ".config", "auth", "credential", "credentials", "token", "secret"}


def _safe(relative: Path) -> bool:
    return not relative.is_absolute() and ".." not in relative.parts and not any(part.lower() in FORBIDDEN for part in relative.parts)


def _write(archive: ZipFile, name: str, data: bytes) -> None:
    item = ZipInfo(name, (1980, 1, 1, 0, 0, 0))
    item.compress_type = ZIP_DEFLATED
    archive.writestr(item, data)


def package(root: Path, files: list[str], output: Path, complete: bool = True) -> dict:
    if not complete:
        raise ValueError("incomplete evidence cannot be packaged")
    inventory = []
    with ZipFile(output, "w", ZIP_DEFLATED) as archive:
        for name in sorted(files):
            relative = Path(name)
            if not _safe(relative):
                raise ValueError("forbidden evidence path")
            path = root / relative
            if not path.is_file():
                raise ValueError("missing evidence artifact")
            data = path.read_bytes()
            _write(archive, relative.as_posix(), data)
            inventory.append({"path": relative.as_posix(), "sha256": hashlib.sha256(data).hexdigest(), "bytes": len(data)})
        _write(archive, "inventory.json", json.dumps(inventory, sort_keys=True, separators=(",", ":")).encode())
    return {"artifacts": inventory, "sha256": hashlib.sha256(output.read_bytes()).hexdigest()}


def verify(bundle: Path) -> bool:
    try:
        with ZipFile(bundle) as archive:
            inventory = json.loads(archive.read("inventory.json"))
            return all(hashlib.sha256(archive.read(item["path"])).hexdigest() == item["sha256"] for item in inventory)
    except (KeyError, OSError, ValueError):
        return False

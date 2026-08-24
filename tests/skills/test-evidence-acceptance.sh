#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
bash "$ROOT/tests/tools/test-write-evidence.sh"
bash "$ROOT/tests/tools/test-evidence-migration.sh"
bash "$ROOT/tests/hooks/test-drift-check.sh"
bash "$ROOT/tests/skills/test-update-evidence-policy.sh"
bash "$ROOT/tests/live/test-live-runtime.sh"
printf 'PASS: evidence acceptance matrix\n'

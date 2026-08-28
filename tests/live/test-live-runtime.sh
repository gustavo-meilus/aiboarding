#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

printf '%s\n' \
  '#!/usr/bin/env bash' \
  'case "${1:-}" in' \
  "  --version) printf 'fake-runtime 1.0\\n'; exit 0 ;;" \
  '  plugin) exit 0 ;;' \
  'esac' \
  'printf x >> "${AIBOARDING_INVOCATION_COUNT_FILE:?}"' \
  'fake_cwd="${AIBOARDING_LIVE_SCRATCH//\\/\\\\}"' \
  'case "${AIBOARDING_FAKE_MODE:-ok}" in' \
  "  collector) printf '{\"hook_event_name\":\"UserPromptSubmit\",\"cwd\":\"%s\"}\\n' \"\$fake_cwd\" >> \"\$AIBOARDING_COLLECTOR_FILE\" ;;" \
  "  malformed-collector) printf '{bad\\n' >> \"\$AIBOARDING_COLLECTOR_FILE\" ;;" \
  '  stale-collector) printf "{\\\"hook_event_name\\\":\\\"UserPromptSubmit\\\",\\\"cwd\\\":\\\"/stale\\\"}\\n" >> "$AIBOARDING_COLLECTOR_FILE" ;;' \
  "  wrong-event-collector) printf '{\"hook_event_name\":\"SubagentStart\",\"cwd\":\"%s\"}\\n' \"\$fake_cwd\" >> \"\$AIBOARDING_COLLECTOR_FILE\" ;;" \
  'esac' \
  'case "${AIBOARDING_FAKE_MODE:-ok}:${AIBOARDING_LIVE_CASE:-}" in' \
  '  timeout:*) sleep 2 ;;' \
  '  exit:*) exit 7 ;;' \
  "  malformed:*) printf '{bad\\n' ;;" \
  '  empty:*) : ;;' \
  "  tool:*) printf '{\"type\":\"tool_use\",\"name\":\"shell\"}\\n' ;;" \
  "  error:*) printf '{\"type\":\"error\"}\\n' ;;" \
  "  *:positive) printf '{\"type\":\"result\",\"text\":\"%s\"}\\n' \"\$AIBOARDING_LIVE_CANARY\" ;;" \
  "  *:negative) printf '{\"type\":\"result\",\"text\":\"nothing\"}\\n' ;;" \
  'esac' > "$tmp/fake-runtime"
chmod +x "$tmp/fake-runtime"
run() { AIBOARDING_FAKE_MODE="$1" AIBOARDING_INVOCATION_COUNT_FILE="$tmp/count-$1-$2" python3 "$ROOT/tests/live/verify_runtime.py" --live --runtime "$2" --"$2" "$tmp/fake-runtime" --timeout 1 --evidence-dir "$tmp/evidence-$1-$2" "${@:3}"; }
run_ok() { run "$@" || { cat "$tmp/evidence-$1-$2/summary.json" >&2; return 1; }; }

python3 - "$ROOT/tests/live/verify_runtime.py" "$tmp/windows-hook" <<'PY'
import importlib.util
import json
import sys
from pathlib import Path

spec = importlib.util.spec_from_file_location("verify_runtime", sys.argv[1])
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
home = Path(sys.argv[2]) / "home"
scratch = Path(sys.argv[2]) / "scratch"
home.mkdir(parents=True)
scratch.mkdir()
module.write_codex_collector_hook(home, scratch, scratch / "collector.jsonl", windows=True)
config = json.loads((home / "hooks.json").read_text())
command = config["hooks"]["UserPromptSubmit"][0]["hooks"][0]["commandWindows"]
assert command == r".\aiboarding-user-prompt-submit.cmd"
assert '"' not in command
trampoline = scratch / "aiboarding-user-prompt-submit.cmd"
content = trampoline.read_text()
assert trampoline.is_file()
assert "run-hook.cmd" in content
assert "%~dp0collector.sh" in content and "%~dp0collector.jsonl" in content
PY

mkdir -p "$tmp/lifecycle/.aiboarding/tools"
git -C "$tmp/lifecycle" init -q
cp "$ROOT/templates/tools/write-evidence" "$tmp/lifecycle/.aiboarding/tools/write-evidence"

before="$(git -C "$ROOT" status --porcelain)"
run_ok ok claude
run_ok ok codex
run_ok collector codex --case positive --collect-hooks --install-plugin
[ "$(wc -c < "$tmp/count-collector-codex")" -eq 1 ] || { echo 'FAIL: positive Codex case invoked more than once'; exit 1; }
run_ok ok codex --lifecycle-evidence-project "$tmp/lifecycle"
[ "$(find "$tmp/lifecycle/.aiboarding/evidence/v1" -name '*.json' | wc -l)" -eq 2 ] || { echo 'FAIL: runtime records missing'; exit 1; }
! run ok codex --collect-hooks
! run malformed-collector codex --case positive --collect-hooks
! run stale-collector codex --case positive --collect-hooks
! run wrong-event-collector codex --case positive --collect-hooks
! run tool codex
! run malformed claude
! run empty codex
! run timeout codex
! run exit claude
"$tmp/fake-runtime" --version >/dev/null
PATH="$tmp:$PATH" AIBOARDING_CLAUDE=missing-command python3 "$ROOT/tests/live/verify_runtime.py" --live --runtime claude --evidence-dir "$tmp/degraded" || status=$?
assert_eq "${status:-0}" "2" "missing runtime degrades" || exit 1
PATH="$tmp:$PATH" AIBOARDING_CLAUDE=missing-command python3 "$ROOT/tests/live/verify_runtime.py" --live --strict --runtime claude --evidence-dir "$tmp/strict" || strict_status=$?
assert_eq "${strict_status:-0}" "1" "strict degradation fails" || exit 1
after="$(git -C "$ROOT" status --porcelain)"
assert_eq "$after" "$before" "harness leaves source unchanged" || exit 1
! python3 "$ROOT/tests/live/verify_runtime.py" --runtime claude --evidence-dir "$tmp/refused"
printf 'PASS: live runtime harness\n'

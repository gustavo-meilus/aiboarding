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
run() { AIBOARDING_FAKE_MODE="$1" python3 "$ROOT/tests/live/verify_runtime.py" --live --runtime "$2" --"$2" "$tmp/fake-runtime" --timeout 1 --evidence-dir "$tmp/evidence-$1-$2" "${@:3}"; }
run_ok() { run "$@" || { cat "$tmp/evidence-$1-$2/summary.json" >&2; return 1; }; }

mkdir -p "$tmp/lifecycle/.aiboarding/tools"
git -C "$tmp/lifecycle" init -q
cp "$ROOT/templates/tools/write-evidence" "$tmp/lifecycle/.aiboarding/tools/write-evidence"

before="$(git -C "$ROOT" status --porcelain)"
run_ok ok claude
run_ok ok codex
run_ok ok codex --lifecycle-evidence-project "$tmp/lifecycle"
[ "$(find "$tmp/lifecycle/.aiboarding/evidence/v1" -name '*.json' | wc -l)" -eq 2 ] || { echo 'FAIL: runtime records missing'; exit 1; }
! run ok codex --collect-hooks
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

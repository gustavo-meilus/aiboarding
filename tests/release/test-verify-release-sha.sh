#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
VERIFIER="$ROOT/tools/verify-release-sha"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/gh" <<'EOF'
#!/usr/bin/env bash
case "$TEST_CASE" in
  success) printf 'target\tcompleted\tsuccess\n' ;;
  different) printf 'other\tcompleted\tsuccess\n' ;;
  pending) printf 'target\tin_progress\t\n' ;;
  cancelled) printf 'target\tcompleted\tcancelled\n' ;;
  failed) printf 'target\tcompleted\tfailure\n' ;;
  missing) ;;
esac
EOF
chmod +x "$tmp/gh"

PATH="$tmp:$PATH" TEST_CASE=success bash "$VERIFIER" target
for case_name in different missing pending cancelled failed; do
  if PATH="$tmp:$PATH" TEST_CASE="$case_name" bash "$VERIFIER" target; then
    printf 'FAIL: %s release evidence accepted\n' "$case_name"
    exit 1
  fi
done

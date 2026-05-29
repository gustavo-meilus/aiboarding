#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
for t in "$ROOT"/tests/hooks/test-*.sh; do
  [ -f "$t" ] || continue
  printf '== %s ==\n' "$(basename "$t")"
  if bash "$t"; then
    printf 'PASS\n'
  else
    printf 'FAILED\n'
    fail=1
  fi
done
exit "$fail"

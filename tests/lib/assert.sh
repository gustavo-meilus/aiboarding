#!/usr/bin/env bash
# Minimal assertion helpers. No external deps.

assert_contains() {
  # assert_contains "<haystack>" "<needle>" "<message>"
  case "$1" in
    *"$2"*) ;;
    *) printf 'FAIL: %s\n  expected to contain: %s\n  got: %s\n' "$3" "$2" "$1"; return 1 ;;
  esac
}

assert_not_contains() {
  case "$1" in
    *"$2"*) printf 'FAIL: %s\n  expected NOT to contain: %s\n  got: %s\n' "$3" "$2" "$1"; return 1 ;;
    *) ;;
  esac
}

assert_eq() {
  if [ "$1" != "$2" ]; then
    printf 'FAIL: %s\n  expected: %s\n  got: %s\n' "$3" "$2" "$1"; return 1
  fi
}

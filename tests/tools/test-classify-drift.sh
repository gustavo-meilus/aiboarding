#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
TOOL="$ROOT/skills/update-agent-onboarding/classify-drift"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
git -C "$tmp" init -q
git -C "$tmp" config user.email t@t.t
git -C "$tmp" config user.name t
mkdir -p "$tmp/.aiboarding"
printf '{\n  "ignored_paths": [\n    "ops/*",\n    "package.json"\n  ],\n  "high_risk_paths": [\n    "ops/critical/*"\n  ]\n}\n' > "$tmp/.aiboarding/config.json"
printf 'base\n' > "$tmp/file.txt"
git -C "$tmp" add .
git -C "$tmp" commit -qm base
base="$(git -C "$tmp" rev-parse HEAD)"

check() {
  local path="$1" expected="$2" semantic="${3:-}"
  mkdir -p "$tmp/$(dirname "$path")"
  printf '%s\n' "$path" > "$tmp/$path"
  git -C "$tmp" add "$path"
  git -C "$tmp" commit -qm "$path"
  local head out args=()
  head="$(git -C "$tmp" rev-parse HEAD)"
  [ -z "$semantic" ] || args=(--semantic "$semantic")
  out="$(bash "$TOOL" --project "$tmp" --base "$base" --head "$head" "${args[@]}")"
  assert_contains "$out" "\"route\":\"$expected\"" "$path routes $expected" || exit 1
  git -C "$tmp" reset --hard -q "$base"
}

check package.json mandatory-revalidation complete-no-op
check Makefile mandatory-revalidation
check .github/workflows/test.yml mandatory-revalidation
check Dockerfile mandatory-revalidation
check schema/users.sql mandatory-revalidation
check migrations/001.sql mandatory-revalidation
check ARCHITECTURE.md mandatory-revalidation
check src/app.sh semantic-review
check README.md semantic-review
check ops/ignored.txt irrelevant
check ops/critical/value mandatory-revalidation
check AGENTS.md irrelevant
check CLAUDE.md irrelevant
check .aiboarding/state.json irrelevant
check .aiboarding/evidence/v1/record.json irrelevant

# In-sync requires no classifier route in adapters; the classifier's empty
# range is still fail-safe if an adapter calls it accidentally.
out="$(bash "$TOOL" --project "$tmp" --base "$base" --head "$base")"
assert_contains "$out" '"route":"invalid-pointer"' "empty range is uncertain" || exit 1

mkdir -p "$tmp/ops" "$tmp/src"
printf 'ignored\n' > "$tmp/ops/ignored.txt"
printf 'code\n' > "$tmp/src/app.sh"
git -C "$tmp" add ops/ignored.txt src/app.sh
git -C "$tmp" commit -qm mixed
head="$(git -C "$tmp" rev-parse HEAD)"
out="$(bash "$TOOL" --project "$tmp" --base "$base" --head "$head")"
assert_contains "$out" '"route":"semantic-review"' "mixed range remains relevant" || exit 1
git -C "$tmp" reset --hard -q "$base"

printf 'x\n' > "$tmp/file.txt"
git -C "$tmp" add file.txt
git -C "$tmp" commit -qm source
head="$(git -C "$tmp" rev-parse HEAD)"
out="$(bash "$TOOL" --project "$tmp" --base "$base" --head "$head" --semantic complete-no-op)"
assert_contains "$out" '"route":"irrelevant"' "complete semantic evidence permits no-op" || exit 1
out="$(bash "$TOOL" --project "$tmp" --base deadbeef --head "$head")"
assert_contains "$out" '"route":"invalid-pointer"' "malformed pointer is invalid" || exit 1
git -C "$tmp" checkout -qb rebased "$base"
printf 'rebased\n' > "$tmp/rebased.txt"
git -C "$tmp" add rebased.txt && git -C "$tmp" commit -qm rebased
out="$(bash "$TOOL" --project "$tmp" --base "$head" --head HEAD)"
assert_contains "$out" '"route":"invalid-pointer"' "rebased range is invalid" || exit 1
printf 'PASS: classify-drift\n'

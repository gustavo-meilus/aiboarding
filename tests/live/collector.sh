#!/usr/bin/env bash
# Test-only inert hook observer. A case supplies its output path as $1.
set -euo pipefail
collector_file="${1:-${AIBOARDING_COLLECTOR_FILE:-}}"
[ -n "$collector_file" ] || exit 0
mkdir -p "$(dirname "$collector_file")"
tee -a "$collector_file" > /dev/null
printf '\n' >> "$collector_file"

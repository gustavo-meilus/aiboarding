#!/usr/bin/env bash
# Test-only inert hook observer. A case opts in with AIBOARDING_COLLECTOR_FILE.
set -euo pipefail
[ -n "${AIBOARDING_COLLECTOR_FILE:-}" ] || exit 0
mkdir -p "$(dirname "$AIBOARDING_COLLECTOR_FILE")"
tee -a "$AIBOARDING_COLLECTOR_FILE" > /dev/null
printf '\n' >> "$AIBOARDING_COLLECTOR_FILE"

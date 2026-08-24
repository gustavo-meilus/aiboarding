## Why

AIBoarding's executable test harness and deterministic plugin checks are not authoritative repository gates, so changes and releases can be accepted based only on local, self-reported verification. Independent CI evidence must identify and validate the exact commit being proposed or released.

## What Changes

- Run the existing Bash harness for proposed changes and pushes, preserving it as the source of deterministic test behavior.
- Run deterministic plugin and manifest validation in CI and report any failure as a failed check.
- Preserve the existing security scan while adding engineering verification for materially different supported host environments.
- Record the verified commit SHA in successful CI output.
- Require release preparation to confirm that required checks passed for the exact release target commit; local or agent-reported results are insufficient.
- Add regression proof that failing harness and manifest fixtures make CI fail and that unverified or failing target SHAs cannot satisfy release verification.

## Capabilities

### New Capabilities

- `executable-verification`: Authoritative CI and release verification requirements for repository changes and exact target commits.

### Modified Capabilities

None.

## Impact

- GitHub Actions workflows and repository check configuration.
- Existing `tests/run.sh` harness and deterministic plugin validation entry points.
- Release skill and runbook preflight requirements.
- GitHub repository permissions and required-check policy; existing security scanning remains active.

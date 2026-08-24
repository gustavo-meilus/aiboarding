## 1. Executable CI Gate

- [x] 1.1 Add a harness-discovered CI contract test covering pull-request and `main` push triggers, Ubuntu and Windows Git Bash jobs, exact-SHA output, the single `bash tests/run.sh` entry point, and continued security workflow triggers/failure settings; run it first and verify it fails because executable verification is absent.
- [x] 1.2 Add the thin executable-verification GitHub Actions workflow with stable matrix job names and verify the CI contract test plus `bash tests/run.sh` pass locally.
- [x] 1.3 Confirm deterministic manifest validation remains owned by `tests/plugin/test-manifests.sh` and verify a temporary invalid manifest makes `bash tests/run.sh` exit non-zero before restoring the manifest.

## 2. Exact-Commit Release Verification

- [x] 2.1 Add a shell regression test with a stubbed `gh` covering exact-SHA success and different-SHA, missing, pending, cancelled, and failed-run rejection; run it first and verify it fails because the release verifier is absent.
- [x] 2.2 Implement the minimal exact-SHA release verifier for the engineering and security workflows and verify the regression test and full Bash harness pass.
- [x] 2.3 Update the release skill, release runbook, `docs/VERIFICATION.md`, and README statements so release preparation requires the verifier for an explicit target SHA and no text still permits direct-push or local-only proof; verify with focused `rg` checks and `bash tests/run.sh`.

## 3. Authoritative Repository Enforcement

- [x] 3.1 Open the implementation pull request, introduce a controlled harness failure in a disposable commit, and record the failed executable-verification run URL and SHA; restore the change in a new commit and record green engineering and security run URLs for the corrected SHA.
- [x] 3.2 Merge only the corrected pull request and verify both workflows complete successfully for the exact resulting `main` SHA, their output identifies that SHA, and the release verifier accepts it.
- [x] 3.3 Verify the release verifier rejects an unverified or failing repository SHA and exits non-zero rather than warning.
- [x] 3.4 After required check contexts exist, configure a `main` repository ruleset requiring pull requests, both platform verification contexts, and the existing security scan with no routine bypass; query the ruleset and verify all observed contexts are required.
- [x] 3.5 Attempt or inspect a blocked change path to verify `main` cannot accept a change while any required check fails, then run `bash tests/run.sh` and confirm the security scan remains enabled with its original permissions, threshold, SARIF upload, and pinned actions.

### Verification evidence

- Failing PR canary: `429770e4aa6b951168d4ad5a49fd62cf5ab7d3d5`, [failed executable verification](https://github.com/gustavo-meilus/aiboarding/actions/runs/32659611762).
- Corrected PR SHA: `9a339b36741d571c766552763069042e3dd8245b`, [engineering](https://github.com/gustavo-meilus/aiboarding/actions/runs/32659669700) and [security](https://github.com/gustavo-meilus/aiboarding/actions/runs/32659669692) succeeded.
- Merged main SHA: `53537b716115f99950cdb1c378885a5beb4a9941`, [engineering](https://github.com/gustavo-meilus/aiboarding/actions/runs/32659745546) and [security](https://github.com/gustavo-meilus/aiboarding/actions/runs/32659745608) succeeded; `tools/verify-release-sha` accepted it.
- Ruleset `21246674` requires `Executable Verification (Ubuntu)`, `Executable Verification (Windows Git Bash)`, and `scan`; failing PR #6 was rejected by its base branch policy.

## Context

See `proposal.md` for motivation and `specs/executable-verification/spec.md` for required behavior. The repository currently has one GitHub Actions workflow, `hol-plugin-scanner.yml`, which performs security scanning on pull requests and pushes. `tests/run.sh` already discovers the hook, tool, and plugin contract tests, including deterministic manifest validation. GitHub reports no branch protection or rulesets for `main`, while the release skill and runbook explicitly permit direct pushes and local-only verification.

The release process already depends on `gh`, so exact-commit verification can use GitHub's recorded workflow data without adding a service or package. Windows Git Bash is a materially different supported shell/path environment from Ubuntu; no repository evidence establishes a separate macOS behavior contract.

## Goals / Non-Goals

**Goals:**

- Keep workflow logic thin by invoking the existing harness unchanged.
- Make stable engineering and security check contexts required before changes enter `main`.
- Verify release targets against completed successful push runs recorded for the exact SHA.
- Leave one deterministic regression check for release-SHA selection and collect an actual failing/green CI canary.

**Non-Goals:**

- Automate live Claude runtime protocols from `docs/VERIFICATION.md`.
- Add an LLM, new validation framework, or duplicate manifest rules in YAML.
- Add macOS CI without evidence of materially distinct supported behavior.
- Automate release creation or deployment.

## Decisions

### Add one thin executable-verification workflow

Add a workflow triggered by pull requests to and pushes on `main`. Its matrix uses Ubuntu and Windows, checks out the triggering commit, prints the tested `GITHUB_SHA`, and invokes `bash tests/run.sh`; the Windows job explicitly uses Git Bash. Matrix job names remain stable so repository rules can require them.

This reuses the harness, including `tests/plugin/test-manifests.sh`, instead of reproducing assertions in workflow YAML or introducing another test runner. macOS is omitted until a supported behavior differs there.

Alternative considered: add separate manifest workflow steps. Rejected because the harness already owns discovery and failure propagation; a second invocation adds no coverage and can drift.

### Preserve security scanning as an independent required check

Keep `hol-plugin-scanner.yml` and its permissions, triggers, threshold, SARIF upload, and failure behavior intact. Configure the `main` repository rule to require its stable scan context alongside both executable-verification matrix contexts.

Alternative considered: merge scanning into the new workflow. Rejected because it risks changing established security permissions and behavior without improving verification.

### Protect `main` after checks exist

After the new workflow has produced its check contexts, create a repository ruleset for `main` that requires pull requests and the engineering/security status checks, without a routine bypass. This closes the current direct-push path; pushes still trigger verification so the exact merged commit receives recorded evidence.

Alternative considered: rely on workflow files and maintainer convention. Rejected because workflows alone record results but do not prevent unverified changes from entering `main`.

### Add a small exact-SHA release verifier

Add one repository script that accepts an explicit target SHA, queries GitHub Actions through the already-required `gh` CLI for successful completed push runs of the engineering and security workflows, verifies every returned `headSha` equals the target, and exits non-zero for missing, pending, cancelled, or failed evidence. Keep required workflow identities fixed in the script because they are repository invariants, not user configuration.

Update the release skill and runbook to require this script before tagging and to use an explicit commit SHA rather than treating local command output as proof. Add one shell regression test that replaces `gh` with deterministic fixtures covering exact-match success, different-SHA rejection, and unsuccessful or missing-run rejection.

Alternative considered: embed `gh run list` snippets only in release prose. Rejected because the pass/fail logic would lack executable regression proof and could diverge between documents.

### Prove CI failure and recovery with a disposable canary

Use a temporary pull request that changes a controlled test fixture or test expectation so `tests/run.sh` fails. Record the failing workflow URL and SHA, restore the fixture in the same branch, then record the green workflow URL and corrected SHA. Do not merge the intentionally failing commit.

## Risks / Trade-offs

- [Windows runner exposes shell incompatibility in previously Linux-only assumptions] - Fix only genuine supported-platform failures in the existing harness; do not fork assertions by platform unless behavior is intentionally different.
- [Required check names drift after workflow or job renaming] - Use explicit stable job names and verify the repository ruleset after configuration changes.
- [Ruleset enabled before check contexts exist can block merging] - Land and run workflows first, then enable and query the ruleset.
- [GitHub outage or delayed run blocks a release] - Fail closed and retry after externally recorded checks complete; never downgrade to local prose evidence.
- [Security workflow action changes upstream] - Preserve its pinned action revisions and current permissions in this change.

## Migration Plan

1. Add the executable-verification workflow, exact-SHA verifier, its regression test, and release guidance changes in a pull request while existing repository access remains unchanged.
2. Run both workflows on the pull request and on its merged `main` SHA; confirm output records that SHA.
3. Run the disposable failing/restored canary and retain links to both CI outcomes.
4. Enable the `main` ruleset requiring pull requests and the observed engineering/security check contexts; query the ruleset to confirm no required context is missing.
5. Run release verification against one green exact SHA and fixture-backed negative cases.

Rollback: disable the ruleset before reverting workflow or check names, then revert the new workflow, verifier, and release guidance. Leave the pre-existing security workflow unchanged throughout.

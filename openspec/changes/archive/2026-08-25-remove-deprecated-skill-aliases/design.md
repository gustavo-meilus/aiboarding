## Context

AIBoarding publishes every directory under `skills/` as part of its Claude and Codex plugin distributions and supports copying the same directory into other agents' discovery paths. Two directories are compatibility-only stubs that delegate to canonical skills. Current docs and tests deliberately count those aliases, and the legacy drift hook still emits one retired name. See `proposal.md` for the removal rationale and `specs/plugin-skill-catalog/spec.md` for the resulting catalog contract.

The repository also self-hosts installed hook copies under `.aiboarding/hooks/`; those copies must remain byte-identical to `templates/hooks/`. Historical `CHANGELOG.md` and `RELEASE-NOTES.md` entries are release records rather than current usage guidance.

The final self-host audit exposed two unrelated false positives: its command checker included arguments in the executable path, and its recursive file discovery included fixture onboarding documents.

## Goals / Non-Goals

**Goals:**

- Remove both alias directories at the distribution source.
- Make automated checks assert the five supported skills and reject reintroduction of either retired name.
- Remove retired names from active documentation and emitted lifecycle guidance.
- Keep template and self-hosted hook copies identical.

**Non-Goals:**

- Removing `migrate-aiboarding` or the legacy-layout detection and migration path.
- Rewriting historical release records.
- Adding replacement aliases, redirects, feature flags, or runtime compatibility shims.

## Decisions

### Delete aliases instead of retaining tombstones

Delete `skills/create-aiboarding/` and `skills/update-aiboarding/`. Skill discovery is directory-based, so deletion is the responsible layer and requires no manifest changes. A tombstone would continue exposing the names this change retires.

Alternative: keep stubs that emit a harder warning. Rejected because it preserves the deprecated surface and does not satisfy removal.

### Assert the supported catalog and retired-name absence in the existing manifest test

Replace the seven-skill/deprecation assertions with the five canonical skill expectations plus explicit absence checks for both retired directories. This keeps the packaging invariant in the existing test that owns skill discovery.

Alternative: rely only on the generic frontmatter loop. Rejected because it would not fail if a retired directory returned.

### Update only active references

Remove availability claims and deprecated alias entries from `README.md` and current verification guidance. Replace the legacy drift nudge with `migrate-aiboarding`, the supported workflow for a legacy layout. Leave changelogs, release notes, and dated design history intact because changing them would falsify historical behavior.

Alternative: remove every textual occurrence repository-wide. Rejected because historical records and archived plans intentionally describe prior releases.

### Keep installed hook copies synchronized

Apply the drift-nudge text change to both `templates/hooks/drift-check` and `.aiboarding/hooks/drift-check`, then use the existing self-host verification to prove byte identity.

Alternative: update only the template and defer the installed copy. Rejected because it violates the repository's managed-layout invariant immediately.

### Audit executable paths and exclude test fixtures

Extract only the executable path from shell command examples before checking its existence, and prune `tests/fixtures/` from audit discovery. This preserves validation of live onboarding guidance while keeping test corpus content from contaminating a repository-level audit.

Alternative: relax stale-command validation globally. Rejected because it would hide genuine broken command paths in operational guidance.

## Risks / Trade-offs

- [Existing callers fail after upgrade] → Mark the change breaking and publish the direct old-to-new command mapping.
- [A stale active reference remains] → Search active docs, skills, templates, tests, and hooks for both names while excluding historical and archived records from removal.
- [Template and self-host hook copies diverge] → Change both together and run the self-host managed-repo check.
- [Self-host audit cannot certify the change] → Parse command examples correctly and exclude fixture-only onboarding before running the audit gate.

## Migration Plan

1. Update callers from `create-aiboarding` to `create-agent-onboarding` and from `update-aiboarding` to `update-agent-onboarding`.
2. Delete the two alias skill directories and update current guidance, hook text, and catalog assertions in one release.
3. Run the full and self-host verification suites before publishing.

Rollback is a source-level revert that restores both alias directories and their catalog assertions; no persisted user data or generated onboarding files require migration.

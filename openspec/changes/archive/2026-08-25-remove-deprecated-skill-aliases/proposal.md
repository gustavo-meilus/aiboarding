## Why

The deprecated `create-aiboarding` and `update-aiboarding` aliases keep obsolete command names in every plugin and copied-skill installation after users have had a migration path to the canonical names. Removing the stubs makes the supported skill surface unambiguous and avoids maintaining compatibility-only entries.

## What Changes

- **BREAKING**: Remove the `create-aiboarding` and `update-aiboarding` skill aliases, so those command names no longer resolve.
- Keep `create-agent-onboarding` and `update-agent-onboarding` as the canonical create and update skills.
- Update current documentation, lifecycle nudges, and plugin tests so they advertise and verify only the supported skill names.
- Correct the self-host audit gate so it ignores test fixtures and validates command paths without treating their arguments as paths.
- Preserve `migrate-aiboarding` and legacy `AIBOARDING.md` migration behavior; this change does not remove legacy-layout support.
- Preserve historical changelog and release-note entries that describe releases where the aliases existed.

## Capabilities

### New Capabilities

- `plugin-skill-catalog`: Defines the supported AIBoarding skill set exposed by plugin and copied-skill installations, including the absence of retired aliases.

### Modified Capabilities

None.

## Impact

- Removes `skills/create-aiboarding/` and `skills/update-aiboarding/` from distributed skill discovery.
- Changes the plugin manifest test expectations and current skill-count documentation.
- Updates README guidance and the legacy drift nudge that still names `update-aiboarding`.
- Users or automation invoking either retired alias must switch to `create-agent-onboarding` or `update-agent-onboarding`.
- The audit continues to report genuine onboarding problems without false failures from repository test data.

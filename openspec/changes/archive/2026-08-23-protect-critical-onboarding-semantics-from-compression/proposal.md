## Why

AIBoarding's clarity exemptions limit compression aggressiveness but still permit semantic rewriting of instructions whose negation, modality, ordering, authorization, or escalation conditions govern safe agent behavior. Byte-preserving syntax cannot prove those instructions retained their force, so default token savings must yield to verbatim preservation in high-consequence regions.

## What Changes

- Define a narrow high-consequence policy covering guardrails, escalation conditions, security constraints, destructive or irreversible action constraints, and ordered safety or migration procedures, including equivalent content outside canonical headings.
- Exempt high-consequence instruction regions from semantic rewriting by default while continuing the selected compression level for ordinary descriptive prose.
- Permit stronger rewriting only after an explicit user opt-in for the identified high-consequence content; existing compression levels remain unchanged for lower-risk content.
- Extend compression receipts and user-facing reports to distinguish content preserved under the high-consequence policy from content compressed normally.
- Add adversarial compression fixtures for negation, modality, ordering, authorization, escalation, security, and destructive-action wording while retaining existing byte-preservation checks.

## Capabilities

### New Capabilities

- `high-consequence-compression-preservation`: Defines classification, default verbatim preservation, explicit rewrite opt-in, reporting, and compatibility behavior for high-consequence onboarding instructions.

### Modified Capabilities

None.

## Impact

Affected surfaces include the `compress-onboarding` contract, create/update compression guidance, compression fixtures and tests, `.aiboarding/state.json` receipt entries, and `audit-agent-onboarding --stats` rendering. Existing files and receipt fields remain readable; the policy adds preservation evidence without changing compression level names, ordinary low-risk compression, or current byte-preservation guarantees.

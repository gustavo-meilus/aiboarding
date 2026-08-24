## Why

The onboarding audit currently presents mechanically verified failures and model judgments as equivalent findings, hiding how strongly repository state supports each result. Separating computed evidence from inferred review makes reports more trustworthy and lets deterministic checks run without an agent.

## What Changes

- Classify every existing audit category by the strongest evidence it can reliably produce: computed, inferred, or a category with separate computed and inferred subchecks.
- Add dependency-light, independently runnable validators for wrapper integrity, file and instruction-chain budgets, and mechanically resolvable command references.
- Give every finding an evidence provenance distinct from its FAIL/WARN/INFO severity.
- Make the audit skill run deterministic validators before semantic review and combine both result sets without overstating model judgments as proof.
- Add fixtures for deterministic outcomes and a mixed report example containing computed and inferred findings.
- Preserve the audit's read-only behavior, recognizable categories, and handoff to existing remediation skills.

## Capabilities

### New Capabilities

- `onboarding-audit-evidence`: Defines independently runnable deterministic onboarding validation and evidence-aware orchestration and reporting.

### Modified Capabilities

None.

## Impact

- Affects `skills/audit-agent-onboarding/SKILL.md`, portable tooling under `templates/tools/`, tool installation/manifests where required, and focused shell fixtures/tests.
- Changes audit report presentation by adding evidence provenance while retaining existing severity and read-only behavior.
- Adds no runtime service or heavyweight dependency.

## Why

AIBoarding validates its managed onboarding lifecycle mainly through fixtures, while its own repository lacks the canonical artifacts that users receive. Self-hosting makes normal maintainer work exercise the product's real create, update, compress, audit, and drift contracts continuously.

## What Changes

- Add the repository's canonical `AGENTS.md`, thin `CLAUDE.md` adapter, and `.aiboarding/` operational state, tools, and hooks through the supported public lifecycle.
- Wire the standard Claude Code hook entries without duplicating canonical guidance in runtime-specific files.
- Add repository-level acceptance coverage for setup idempotency, no-op updates, relevant drift, audit, compression preservation, and loop-free state advancement.
- Keep existing plugin packaging, templates, fixtures, skills, and Bash tests intact.

## Capabilities

### New Capabilities

- `self-hosted-onboarding`: AIBoarding repository participates in its own managed onboarding lifecycle and serves as an end-to-end acceptance case.

### Modified Capabilities

None.

## Impact

Adds root onboarding documents, committed `.aiboarding/` lifecycle files, Claude settings integration, and self-host acceptance checks. No public API, schema, dependency, fixture, or user-facing lifecycle behavior changes.

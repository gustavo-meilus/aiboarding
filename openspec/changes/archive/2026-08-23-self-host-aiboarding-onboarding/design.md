## Context

See `proposal.md` for motivation and `specs/self-hosted-onboarding/spec.md` for behavior. Current lifecycle is instruction-driven: public skills create and update repository artifacts, deterministic hooks and tools are copied from `templates/`, and `tests/run.sh` verifies those deterministic pieces against fixtures. The project root currently has none of its own managed artifacts.

Self-hosting has one unusual constraint: a committed state pointer cannot name the commit containing that same pointer. Existing lifecycle design already handles this by ignoring `AGENTS.md`, `CLAUDE.md`, and `.aiboarding/*` during drift evaluation.

## Goals / Non-Goals

**Goals:**

- Bootstrap and maintain the root through existing public lifecycle contracts.
- Make template or lifecycle regressions visible in normal repository verification.
- Prove instruction-driven branches with focused self-host protocols while keeping deterministic checks automated.
- Keep canonical guidance concise and operational state unloaded.

**Non-Goals:**

- Add a second installer, self-host schema, orchestration loop, or replacement for fixture tests.
- Automate subjective onboarding-content synthesis in Bash.
- Change public lifecycle semantics solely to accommodate this repository.

## Decisions

### Bootstrap with the public create lifecycle

Run `create-agent-onboarding` against the repository and commit its normal outputs: root guidance, thin wrapper, state/config, copied hooks/tools, and merged Claude settings. Repository evidence and the supplied change intent provide the initial domain input; ask only about material gaps found during apply.

Alternative considered: hand-maintain a reduced self-host layout. Rejected because it would not exercise the product users receive.

### Keep generated copies as real installed artifacts

Commit `.aiboarding/hooks/` and `.aiboarding/tools/` exactly as setup installs them. Acceptance checks compare installed copies with source templates and validate a single settings entry per event. Template changes therefore make the repository visibly stale until the public setup lifecycle refreshes it.

Alternative considered: symlink installed files to `templates/`. Rejected because symlinks differ from user installs and reduce Windows portability.

### Combine automated structure checks with executed skill protocols

Extend the Bash harness with a self-host check for canonical schema, wrapper integrity, budget, managed-copy parity, hook uniqueness, state/config shape, and deterministic idempotency surfaces. Add a short self-host protocol to the verification runbook for instruction-driven create, update, audit, and compression branches that Bash cannot honestly execute.

During implementation, execute and record the protocol against this checkout: repeat setup, hash instruction files around a no-op update, introduce a controlled relevant delta, audit, run compression preservation, and run `bash tests/run.sh`. Controlled drift probes MUST restore the checkout after measurement and preserve unrelated user work.

Alternative considered: encode agent reasoning in a new shell test. Rejected because it would create a second, inaccurate implementation of skill behavior.

### Configure self-host drift around authoritative inputs

Use normal `.aiboarding/config.json` customization, not new code. Do not ignore `README.md` in this repository because it is an authoritative source for purpose, architecture, and commands. Continue always-ignoring managed instruction/state paths through the existing update and drift contracts, preventing onboarding-only commits from looping.

Alternative considered: keep the template's default README exclusion. Rejected because material README-only changes would evade this repository's acceptance goal.

## Risks / Trade-offs

- [Instruction-driven checks cannot be fully deterministic] - Keep objective invariants in Bash and document exact manual acceptance evidence for reasoning branches.
- [Installed template copies can become stale] - Fail self-host parity checks until setup refreshes them; this is intentional product dogfooding.
- [Sync pointer trails an onboarding-only commit] - Existing ignored-path logic suppresses that range; the next relevant commit remains detectable.
- [Canonical guidance drifts toward README duplication] - Audit for near-duplication and keep detail in linked docs rather than always-loaded instructions.

## Migration Plan

1. Run the public create lifecycle, review its approval-gated canonical document, and install standard managed artifacts.
2. Customize only repository-owned configuration needed for authoritative drift inputs.
3. Add automated self-host integrity checks and the instruction-driven verification protocol.
4. Run repeated setup, update branches, audit, compression preservation, and the full Bash suite.
5. Roll back by removing the newly managed root artifacts, `.aiboarding/`, self-host settings entries, and self-host acceptance additions; no external data or public schema migration is involved.

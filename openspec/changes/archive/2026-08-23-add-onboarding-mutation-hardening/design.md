## Context

See `proposal.md` for motivation and `specs/onboarding-mutation-verification/spec.md` for behavior. Current compression verification compares hand-authored before/after fixtures with `check-preservation`; the audit skill describes repository-wide checks but currently mixes model judgment with the one executable size check. The parallel `make-onboarding-audit-evidence-aware` change defines a single deterministic audit command and explicit `computed`/`inferred` finding provenance. This change must reuse those sensors, the existing Bash test conventions, and the nine-section `AGENTS.md` contract without creating a general mutation engine.

## Goals / Non-Goals

**Goals:**

- Make realistic semantic corruption measurable with stable mutant identities and positive controls.
- Produce machine-checkable outcomes and a concise human report from the same evidence.
- Keep deterministic execution separate from recorded semantic review.
- Make regressions, unknown results, and surviving mutants impossible to confuse with a clean score.

**Non-Goals:**

- Generate arbitrary edits, execute target-repository source code, or auto-fix onboarding files.
- Turn semantic judgment into regex-based pseudo-proof.
- Gate ordinary deterministic tests on an unavailable model runtime or claim corpus completeness.

## Decisions

### Maintain hand-authored scenario fixtures and a small manifest

Store one known-good onboarding scenario and its realistic mutated variants under a dedicated mutation fixture tree. A checked-in manifest gives each mutant a stable ID, operator, surface (`compression` or `audit`), scoring class (`syntax-baseline` or `challenge`), expected harm, applicable sensors, and fixture paths. Corpus validation rejects incomplete records, duplicate IDs, missing files, and missing required operator categories.

Hand-authored mutants keep the harmful meaning reviewable and avoid owning a textual rewrite engine that would mostly generate noise. Existing positive fixtures are referenced or copied only where scenario isolation requires it; they are never replaced by adversarial fixtures.

Alternative considered: dynamically mutate arbitrary onboarding documents with search-and-replace operators. Rejected because applicability and harm would be unreliable, and generated noise would inflate the corpus without testing agent behavior.

### Reuse verification sensors through thin adapters

The mutation runner invokes existing preservation and size checks plus the deterministic audit command defined by `make-onboarding-audit-evidence-aware`. Each adapter normalizes only sensor identity, provenance, and whether its finding is attributable to the seeded defect; it does not reimplement sensor logic. Positive control failure invalidates that scenario instead of killing its mutants.

Initial challenge fixtures cover verification deletion, guardrail weakening and reversal, architecture-direction reversal, runtime/version drift, escalation removal, cross-file contradiction, and nested instruction conflict. The computed instruction-chain budget case and syntax-baseline command mutation verify their established sensors. Compression scenarios run preservation against the original and both positive and mutant outputs; semantic-preserving syntax is not accepted as semantic equivalence.

Alternative considered: build one mutation-specific linter containing every expected rule. Rejected because it would test its own mutation labels rather than the production verification system.

### Run inferred review as an explicit evidence-producing protocol

Model-dependent audit sensors run through the public audit workflow against the same fixture repositories. The protocol emits one normalized evidence record per applicable mutant and sensor, including corpus fingerprint, audit skill revision, runtime/model identity, outcome, finding category, and affected locations. The aggregator rejects missing, malformed, or stale inferred evidence rather than treating it as a survivor or a pass.

This makes final reports reproducible from recorded inputs while keeping semantic reruns honest: a rerun creates a separately identified evidence set and cannot silently overwrite computed results. The maintained report may record inference variance across runs, but only a finding attributable to the seeded defect kills the mutant.

Alternative considered: invoke a model from the Bash suite. Rejected because no stable model CLI or credentials are part of the repository contract, and it would make ordinary tests network-dependent.

### Use one outcome model and exclude baseline kills from the primary score

After every applicable sensor has a result, a mutant is `killed` when any sensor detects its seeded defect and `survived` otherwise. Multiple sensors never multiply the count. Non-applicable mutants are listed but excluded from denominators. The report shows:

- all applicable mutants, killed mutants, and survivors;
- syntax-baseline outcomes, including protected command mutation;
- challenge mutants, challenge kills, and primary score `challenge kills / applicable challenge mutants`;
- per-mutant detecting sensors with unchanged `computed` or `inferred` provenance;
- survivor gap details and a narrow corpus-coverage disclaimer.

The report command uses distinct statuses: `0` when all applicable mutants are killed, `1` when a complete run has survivors, and `2` when corpus, positive controls, sensor execution, or evidence completeness prevents a valid score. Focused tests assert all three states, so survivors remain machine-visible without forcing network-dependent inference into the ordinary test harness.

Alternative considered: include command-preservation mutants in one overall percentage. Rejected because mechanically guaranteed syntax kills would make semantic coverage look stronger without improving it.

### Check in a canonical report and exact aggregation fixture

The runner emits a stable text report from corpus and evidence records. A checked expected-report fixture proves totals, score math, provenance labels, multiple-sensor de-duplication, non-applicable exclusion, survivor rendering, and status behavior. The maintained canonical report records its corpus fingerprint and evidence identities; `docs/VERIFICATION.md` documents exact computed, inferred, aggregation, and refresh steps.

Alternative considered: document results only in release notes. Rejected because prose cannot be regenerated or checked for score drift.

## Risks / Trade-offs

- [Semantic results vary across models or runs] → Record runtime/model and corpus identity, retain separate runs, and never merge inference into computed evidence.
- [Hand-authored corpus becomes stale or biased] → Require stable operator coverage, explicit harm/applicability review, and visible survivors; add mutants only for observed or credible agent failure modes.
- [Parallel audit hardening changes sensor output] → Consume its documented finding contract through a thin adapter and implement mutation integration after that contract is available.
- [A mutant is killed for an unrelated finding] → Require attribution to the seeded operator and location before counting the kill.
- [Corpus growth slows semantic review] → Keep one representative mutant per distinct failure mode until another case exposes materially different sensor behavior.

## Migration Plan

1. Land or align with the evidence-aware deterministic audit sensor contract.
2. Add corpus manifest, positive controls, mutant fixtures, and corpus validation without changing existing fixtures.
3. Add computed execution, inferred evidence protocol, aggregation, exact report tests, and maintained report.
4. Document reproduction and run focused mutation, preservation, audit, and full repository checks.

Rollback removes the mutation-only fixtures, runner, evidence, and report. Existing tools, audit behavior, positive fixtures, and onboarding files require no migration or data rewrite.

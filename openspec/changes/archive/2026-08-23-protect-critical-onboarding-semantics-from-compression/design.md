## Context

See `proposal.md` and `specs/high-consequence-compression-preservation/spec.md`. Compression is a skill-guided rewrite, not a deterministic text engine. Its current auto-clarity exemptions cap canonical guardrail and escalation sections at `lite` and request full sentences for security, destructive, irreversible, and order-sensitive guidance, but all remain rewriteable. `check-preservation` proves selected syntax survives; it cannot prove semantic equivalence. Compression writes receipts to `.aiboarding/state.json`, and `audit-agent-onboarding --stats` reads them. Nested receipt data is skill-owned; hooks read only top-level scalar state.

## Goals / Non-Goals

**Goals:**

- Remove default semantic drift by copying narrowly identified high-consequence regions unchanged.
- Keep classification understandable and reviewable without pretending a lexical checker can prove semantic risk.
- Preserve existing compression levels and savings on lower-risk prose.
- Add receipt evidence without migrating existing state or breaking older readers.

**Non-Goals:**

- Build a general semantic-equivalence engine or regex safety classifier.
- Freeze all onboarding content or change existing protected-span definitions.
- Persist blanket permission to rewrite future high-consequence content.

## Decisions

### Preserve complete regions instead of attempting safer paraphrases

The compressor first identifies high-consequence regions, then copies them byte-for-byte into the candidate output. Canonical `Agent Guardrails` and `Escalation - Ask the User When` sections are preserved whole. Elsewhere, the unit is the smallest complete paragraph, list item, warning, or ordered procedure that retains the constraint's conditions and context. Remaining prose follows the selected level.

This is the smallest policy that removes semantic-rewrite risk after classification: byte equality proves an identified region did not drift. Capping rewrites at `lite` was rejected because even polished full sentences can invert negation, weaken modality, or reorder prerequisites. Protecting only cue words was rejected because unchanged words do not preserve their relationships or behavioral force.

### Keep semantic classification in the compression review

The skill uses the normative categories to identify equivalent high-consequence instructions outside canonical headings and presents their locations and categories in the candidate review. Deterministic extraction remains suitable for canonical sections and exact fixture comparisons, but no keyword list is treated as proof that all risky instructions were found.

A new regex classifier was rejected because false negatives would create a misleading safety claim and false positives would freeze ordinary prose. The planned mutation-hardening corpus remains complementary evidence: it challenges classification and policy application without being described as complete proof.

### Require a separate, per-operation rewrite decision

Before rewriting any identified high-consequence region, show its source location and category and ask for explicit authorization scoped to selected regions. Existing compression-level selection and final diff approval do not count as this authorization. The decision is not written to config, preventing future content from inheriting stale consent. Existing protected-span verification and final approval still apply after an authorized rewrite.

A persistent `rewrite_high_consequence` setting was rejected because authorization would silently extend to unseen future instructions. Treating `ultra` as implicit consent was rejected because it changes existing level meaning and subordinates safety to size pressure.

### Add optional region outcomes to each receipt

Receipts gain an optional `high_consequence_regions` array. Each entry records a source section or line location, classification category, outcome (`preserved` or `rewritten`), and whether explicit opt-in was recorded; it does not copy instruction text. The compression result renders the same evidence. `audit-agent-onboarding --stats` renders the field when present and reports `not recorded` when absent.

This additive shape keeps old state valid: old readers ignore nested fields, and new readers distinguish legacy absence from a verified empty list. A new state version or separate evidence file was rejected because no incompatible reader or lifecycle boundary requires either.

### Validate policy with adversarial before/default-output fixtures

Focused fixtures pair mixed-risk source documents with expected default outputs. Tests assert byte equality for canonical sections and each identified external region, ordinary prose reduction, unchanged protected-span behavior, and receipt rendering for preserved, opted-in, empty, and legacy evidence. Fixture cases cover negation, mandatory versus optional modality, authorization, ordered backup/verify/destructive steps, escalation, security, and irreversible actions.

This does not claim general semantic proof. It provides runnable regressions for the stated policy while mutation-hardening supplies broader inferred challenges.

## Risks / Trade-offs

- [Equivalent high-consequence content is not identified] - Keep categories explicit, preserve whole canonical sections, show classification in the review, and exercise equivalent off-heading cases through adversarial and mutation fixtures.
- [Whole canonical sections reduce token savings] - Continue selected compression elsewhere and report preserved regions so the trade-off is visible.
- [Opted-in paraphrase weakens meaning] - Keep opt-in scoped, retain protected-span and final diff gates, and require unambiguous behavioral force; default remains verbatim.
- [Older stats readers omit new evidence] - Use an optional nested receipt field; base receipt data remains unchanged and mixed-version operation stays safe.

## Migration Plan

1. Expand the skill contract and receipt reader to understand optional high-consequence evidence while accepting legacy receipts.
2. Add adversarial mixed-risk fixtures and focused contract tests before changing default rewrite guidance.
3. Change create, update, and standalone compression guidance to classify and preserve regions by default, then run focused preservation, plugin-contract, and full repository checks.
4. Verify new and legacy receipt rendering plus default and explicitly opted-in paths.

Rollback restores prior skill and rendering guidance. Existing receipts, including entries with the optional array, remain valid and may be ignored by older readers; no state rewrite, content rewrite, destructive contraction, or compression-level migration is required.

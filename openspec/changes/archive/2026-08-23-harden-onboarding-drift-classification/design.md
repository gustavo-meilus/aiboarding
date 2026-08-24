## Context

See `proposal.md` for motivation and `specs/onboarding-drift-classification/spec.md` for behavior. Today `templates/hooks/drift-check` reads `.aiboarding/state.json:last_synced_commit`, removes `AGENTS.md`, `CLAUDE.md`, all `.aiboarding/*`, and configured `ignored_paths`, then decides whether to nudge. `skills/update-agent-onboarding/SKILL.md` independently repeats that filtering and lets semantic reasoning choose between targeted review and a state-only pointer advance.

Current ownership and compatibility constraints:

- Readers: `drift-check` reads the pointer and ignored paths; `update-agent-onboarding` reads the pointer, config, Git delta, onboarding sections, and conversation; generic JSON line readers ignore unknown state fields.
- Writers: create and migration skills seed state/config and install project-local hooks/tools; update writes the pointer and receipts after no-op or approved content work.
- Data: state is committed operational JSON with one top-level key per line; onboarding content remains only in `AGENTS.md` and `CLAUDE.md`; config is preserved on repeated setup.
- Distribution: canonical skills live under `skills/`; create copies templates into managed repositories. Existing installed hooks do not update merely because the plugin updates.
- Issue #1 invariant: changing operational state or managed onboarding documents must not make drift detection nudge itself.

## Goals / Non-Goals

**Goals:**

- Give hook and update workflow one deterministic classification authority.
- Make no-op state advancement auditable and conditional on a complete classification.
- Preserve old state/config readability and fail safely when new classification tooling is unavailable.
- Keep content review targeted and approval-gated.

**Non-Goals:**

- Infer semantic onboarding impact in shell code.
- Build a language plugin system or exhaustive ecosystem registry.
- Rewrite existing state history or automatically modify onboarding content during rollout.

## Decisions

### Use one project-local deterministic classifier

Add one executable `classify-drift` companion beside the canonical update skill and install that same file into the existing project-local managed tools set. It accepts base/head commits plus config, validates the range, classifies every changed path, and emits a stable machine-readable report and route. `drift-check` uses only the installed copy's deterministic result to decide silence versus nudge. `update-agent-onboarding` prefers its same-version companion, falling back to the project copy, then asks the tool for the final route after supplying the semantic disposition for potentially relevant paths.

Routes are `irrelevant`, `semantic-review`, `mandatory-revalidation`, and `invalid-pointer`. A definitely relevant result always produces `mandatory-revalidation`, regardless of a semantic no-op input. This makes the non-downgrade rule executable and directly testable instead of relying on duplicated prose.

The tool uses Bash and Git already required by hooks; no dependency is added. It is self-contained so a manual cross-agent copy of the skill directory carries its classifier without Claude hook files. If both companion and installed copies are unavailable, update must choose full revalidation; a hook missing the installed copy must nudge.

Alternative considered: encode pattern lists separately in the hook and skill. Rejected because the two copies can disagree at the exact state-advancement boundary being hardened.

### Apply explicit classification precedence

Classification order is:

1. Reject missing, malformed, unresolvable, empty, or moving ranges as uncertain.
2. Treat exact managed bookkeeping paths (`AGENTS.md`, `CLAUDE.md`, and `.aiboarding/state.json`) as always irrelevant for issue #1 loop suppression.
3. Match built-in and configured high-risk signals; these are definitely relevant.
4. Match configured ignored paths; these are provably irrelevant.
5. Classify every remaining path as potentially relevant.

The always-ignored set narrows from `.aiboarding/*` to exact bookkeeping files. Changes to classification config, hooks, or tools therefore cannot hide themselves. High-risk signals precede repository ignores, preventing an overlap from suppressing review.

Built-in signals remain a short, data-driven list of generic path roles and established ecosystem entry points: dependency/runtime manifests and lockfiles; CI workflow surfaces; build, test, container/runtime entry points; schema and migration directories/files; and architecture decision/map surfaces. Configuration adds `high_risk_paths` without changing existing `ignored_paths` syntax. Ordinary source and documentation remain potential, not automatically relevant.

The new config template uses an empty `ignored_paths` list and an empty `high_risk_paths` extension list. In particular it no longer ignores `README.md` or `CHANGELOG.md` by default. Existing repository config remains readable and is not rewritten silently; high-risk precedence still protects overlaps.

Alternative considered: classify every non-bookkeeping path as definitely relevant. Rejected because it eliminates useful semantic triage and effectively treats every commit as onboarding-relevant.

### Separate deterministic category from semantic impact

For potentially relevant deltas, the skill records a section-by-section disposition against all nine onboarding sections. A semantic no-op is accepted only when every potential path is covered and the rationale explains why no section changed. Semantic reasoning may promote paths or sections to relevant.

For definitely relevant deltas, semantic reasoning selects applicable sections and supplies repository meaning, but cannot choose the silent no-op route. Those sections are revalidated. If they remain correct, no content approval is needed because no content changes; the result is recorded as `revalidated-no-content-change`, distinct from `proven-irrelevant`.

Alternative considered: force content edits for every high-risk change. Rejected because review can confirm existing guidance remains accurate, and unnecessary edits would weaken targeted-update preservation.

### Couple pointer advancement with a classification receipt

Extend `state.json` with a `last_drift_classification` top-level object containing `base_commit`, `head_commit`, categorized paths with matched signals, semantic rationale, affected or revalidated sections, and outcome. Old readers continue finding the unique top-level `last_synced_commit` and ignore the new object. Git history preserves prior receipts, so an unbounded in-file log is unnecessary.

Before writing, update rechecks `HEAD`. If it differs from the classified `head_commit`, it discards the result and reclassifies. The pointer and receipt are then written together in one state-file replacement after approved content work or a valid no-content outcome. Unknown existing state fields are preserved.

Alternative considered: a separate append-only classification log. Rejected because committed state history already provides chronology and another mutable file adds synchronization and loop-filtering complexity.

### Keep hook decisions small

The hook remains advisory: in-sync and proven-irrelevant ranges stay silent; potential, definite, malformed, rebased, empty, classifier-failure, and mixed ranges nudge. The nudge includes the deterministic category and decisive signals so update starts with observable evidence. The legacy `AIBOARDING.md` branch retains its exact issue #1 behavior and migration nudge.

## Risks / Trade-offs

- [Built-in signal list misses an uncommon authoritative surface] → classify unmatched paths as potential, allowing semantic escalation, and support repository `high_risk_paths`.
- [A broad configured ignore hides useful low-risk evidence] → high-risk signals win; record ignored matches; document ignored paths as an explicit repository assertion.
- [Large deltas make the state receipt large] → store only the latest receipt in state; rely on Git history for prior evaluations.
- [HEAD changes during review] → compare against recorded `head_commit` immediately before writing and restart classification on mismatch.
- [Existing managed repositories retain an old copied hook] → ship a one-time lifecycle refresh path and document that old hooks remain active until refreshed; updated update workflow still fails toward revalidation when its classifier is absent.
- [Self-trigger regression returns] → always suppress exact onboarding/state bookkeeping ranges and retain issue #1 regression cases.

## Migration Plan

1. Expand: add the skill companion classifier, optional `high_risk_paths`, and optional `last_drift_classification`; update create/migration installers and packaging checks so the companion is copied into project tools. Old state/config remains valid.
2. Integrate: switch new hook templates and update skill to the classifier. Missing tools and unreadable reports nudge or revalidate, never no-op.
3. Refresh: make the updated workflow refresh only AIBoarding-owned classifier and drift-hook files from the current plugin when available; preserve repository config and onboarding content. Document one manual update run after upgrade. Cross-agent users receive the classifier with the updated skill or run manual revalidation if unavailable.
4. Verify: run classifier, hook, manifest, and full repository tests across definite, potential, irrelevant, onboarding-only, malformed, rebased, and mixed ranges. Verify the semantic-no-op input cannot downgrade definite evidence.
5. Rollback: restore prior hook/skill/tool versions. Leave optional config and state fields in place because old readers ignore them; do not rewrite pointers or onboarding content. No contraction or destructive data migration is required.

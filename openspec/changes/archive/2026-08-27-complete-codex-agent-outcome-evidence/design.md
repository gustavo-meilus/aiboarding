## Context

See `proposal.md` for motivation. The canonical `agent-outcome-benchmarking` specification already requires the full condition matrix, six task categories, frozen controls, fresh repeated trials, objective grading, inspectable evidence, explicit unavailable metrics, dispersion, and loss-preserving reporting. The implementation already has one narrow retained Codex experiment plus small modules for condition freezing, task validation, randomized planning, isolated execution, evidence validation/regrading, metrics, aggregation, Markdown rendering, and evidence packaging. The missing behavior is integration and maintained data: `pilot.py` hard-codes one task and two conditions, most task packs are fake-runtime controls, the condition matrix omits degraded/misleading conditions, and the offline modules do not yet produce a complete planned matrix.

The benchmark must remain dependency-free and deterministic except for an explicitly invoked authenticated Codex run. Existing retained experiments remain historical evidence, even where the new profile makes their incompleteness clearer.

## Goals / Non-Goals

**Goals:**

- Make one checked-in Codex profile the frozen source of truth for task/condition applicability, exact artifact provenance, controlled variables, two fresh repetitions, ordering, grader revisions, and expected evidence cells.
- Execute every planned cell through the existing disposable-repository runner and retain enough sanitized evidence for deterministic offline validation and regrading.
- Regenerate metrics, aggregate data, report text, inventory, and package from retained evidence without invoking Codex.
- Fail closed: missing artifacts, grader errors, identity drift, or malformed observations produce visible incomplete cells rather than inferred results.

**Non-Goals:**

- An evidence freshness cadence or automatic supersession policy; “maintained” means a versioned checked-in profile and its retained run, not a recurring paid job.
- A new runner, evidence schema, report format, metric family, dependency, or runtime abstraction.
- Statistical or universal model-quality claims from the deliberately small repetition count.

## Decisions

### 1. The maintained experiment manifest is the only execution plan

Add a frozen smoke experiment/profile under `benchmarks/agent-outcomes/experiments/` using the existing benchmark document shape. It enumerates all six versioned task packs, the `none` and `aiboarding-full` frozen condition artifacts, one repetition, and every controlled-variable identity. `benchmark.py`, `tasks.py`, and `conditions.py` validate cross-references, exact artifact hashes, category completeness, per-task applicability, and the 12-cell smoke set before live execution.

Two repetitions are the smallest count that satisfies the contract's requirement for repeated fresh trials and can expose a disagreement between otherwise controlled cells. Any later increase requires a new frozen experiment identity; results cannot tune this profile after execution begins.

An interrupted profile is likewise immutable: retain every completed partial run through `v6` as incomplete historical evidence and do not resume or overwrite it. The approved cost-controlled `v7` smoke profile has its own frozen identity and does not support full-matrix conclusions.

Alternative considered: infer the plan from directories or command-line condition lists. Rejected because it makes provenance and missing cells ambiguous and permits live arguments to drift from the published experiment.

### 2. Existing task and condition systems become maintained inputs, not test-only placeholders

Complete the six existing task categories with Codex-runnable fixtures, task-independent instructions, retained-file declarations, and deterministic graders that inspect repository state rather than trusting the agent's prose or a benchmark-only success sentinel. Give changed task and grader definitions explicit new revisions and record their hashes; do not reuse identities from `codex-command-discovery-v2` for changed content.

Freeze task-specific condition bundles before trials with the existing `conditions.py` path. Preserve the existing condition classes: `none`, `manual-minimal`, current uncompressed AIBoarding output (`aiboarding-off`), supported `lite`/`full`/`ultra` compression, `stale`, `contradictory`, and naive truncation where the frozen source has a meaningful truncation boundary. Each bundle records its source revision, generation/compression receipt, mutation provenance where applicable, file mapping, content hashes, and any inapplicability reason. The live runner reads frozen bundles only and never regenerates onboarding during a trial.

Codex nested/local `AGENTS.md` precedence is applicable to this profile and remains represented by the existing nested-instructions category; the profile records the runtime support proof. If profile validation cannot establish that proof before freezing, it must reject the profile rather than silently drop the category.

Alternative considered: reuse the current generic condition fixtures unchanged. Rejected because their placeholder text cannot exercise five categories and their matrix omits stale, contradictory, and truncation conditions.

### 3. Extend `pilot.py` into a profile-driven explicit command

Keep `pilot.py` as the only Codex benchmark entry point. Add a profile argument and make it validate/fingerprint the frozen manifest, derive the randomized plan, resolve each task and condition artifact, and call the existing `runner.run_pack` isolation boundary. Preserve the current narrow pilot invocation as a compatibility path for existing local experiments.

For every cell, create a fresh repository and ephemeral Codex session, apply only the selected frozen onboarding bundle, enforce the manifest's model/runtime/tools/permissions/budget/timeout policy, and record independent repository/session identities. Runtime or observed control drift makes the affected comparison incomplete or a distinct experiment; it is never pooled silently.

The adapter retains sanitized Codex JSON events, attempted commands/tool calls, final task files or diff identity, deterministic grader input/output, process status, timing, retries/interventions, and explicit usage availability. A final agent claim cannot override the grader. Grader error, timeout, unknown output, or missing retained input records an incomplete trial without aborting the remaining matrix.

Alternative considered: add a second full-matrix runner. Rejected because the existing pilot and shared live-runtime isolation already own authenticated Codex execution.

### 4. One offline path validates, regrades, aggregates, reports, and packages

Add an offline mode to the existing benchmark command path that starts from a frozen profile plus retained trial directories and composes the existing `evidence.py`, task graders, `metrics.py`, `aggregate.py`, `report.py`, and `package.py` modules. Extend those modules only where the canonical contract is not yet represented:

- validate every planned cell and preserve missing/malformed cells as incomplete;
- rerun the retained deterministic grader definition against retained final state;
- compute the already-required success, false-completion, violation, invalid-command, tool-call, retry, intervention, elapsed-time, and measured-usage observations, using unavailable-with-reason when evidence cannot classify them;
- keep task, condition, repetition, experiment fingerprint, evidence provenance, objective/inferred status, counts, and dispersion linked through aggregation;
- render the complete matrix and measured metric summaries first, then a separate bounded interpretation that keeps neutral and unfavorable AIBoarding comparisons visible;
- package only an allowlisted inventory and verify hashes without exposing credentials or unrelated environment data.

Retained result files use repository-enforced LF normalization so checked-out hashes remain reproducible on Windows; package verification remains authoritative for archived bytes. Offline regeneration writes to a staging directory and replaces publishable outputs only after all validations complete, preventing partial reports from appearing complete.

Alternative considered: hand-author the retained report from the live summary. Rejected because it cannot prove completeness or be reproduced without Codex.

### 5. Deterministic tests exercise the full path without authenticated execution

Add fixture-backed tests that validate the complete profile, reject omitted/mismatched conditions and categories, prove controlled-variable fingerprints, exercise all planned cells through a fake adapter, force grader/error/missing-evidence cases, and regenerate aggregate/report/package output offline. Add retained-evidence integrity checks and assert the ordinary test command never resolves or invokes Codex. The single cost-bearing run remains a documented maintainer command outside `tests/run.sh`.

Alternative considered: cover the integration only with the live run. Rejected because authenticated execution is nondeterministic, costly, and unavailable to ordinary CI.

## Risks / Trade-offs

- [The full matrix is materially larger than the current four trials] → use the approved 12-cell smoke profile: one repetition of `none` and `aiboarding-full` across all six categories, with no full-matrix claim.
- [Task or condition authoring could accidentally encode benchmark answers or favor AIBoarding] → Freeze all artifacts before execution, keep condition meaning stable across tasks, validate provenance, and review task materiality independently of outcomes.
- [Codex event fields may not support a required metric reliably] → Retain sanitized raw events and record the metric as unavailable with a reason; never convert absence to zero or inferred measured fact.
- [A grader revision could invalidate historical identity] → Assign changed definitions new versioned identities and hashes while retaining `codex-command-discovery-v2` and its bundled grader evidence unchanged.
- [One failed live cell could leave a persuasive but incomplete report] → Build reports from the declared plan, show missing/incomplete counts in place, and exclude incomplete comparisons from complete-evidence claims.
- [Cross-platform line ending conversion can break retained hashes] → Enforce LF for retained result paths and verify the packaged inventory in deterministic tests.

## Migration Plan

1. Add and validate the new frozen profile, versioned task packs/graders, and frozen condition bundles without changing retained results.
2. Extend the existing pilot and offline modules; prove the complete flow with deterministic fake-runtime fixtures and `bash tests/run.sh`.
3. Document the exact explicit Codex live command and offline regeneration command.
4. Preserve the partial historical results as incomplete evidence, then freeze and validate the approved `v7` 12-cell smoke profile and run it once with the selected Codex CLI identity; retain every complete or incomplete cell and regenerate the staged report offline without editing outcomes.
5. Verify that incomplete `v7` smoke evidence remains unpublished because packaging refuses it, while retaining the staged report for inspection.

Rollback removes the new profile and its versioned retained result plus the profile-only integration changes. The existing `codex-command-discovery-v2` manifest, evidence bundle, and report remain readable and unchanged throughout.

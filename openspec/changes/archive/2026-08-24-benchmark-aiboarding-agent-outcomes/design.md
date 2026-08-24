## Context

See `proposal.md` for motivation and `specs/agent-outcome-benchmarking/spec.md` for required behavior. The roadmap already reserves v1.0.0 for an onboarding-condition and compression benchmark with a naive-truncation control. Current executable evidence covers Bash contracts and preservation checks; `docs/VERIFICATION.md` still describes manual live protocols. Two planning-complete but currently unimplemented changes define adjacent owners: `add-onboarding-mutation-hardening` owns stable harmful-context scenarios and computed-versus-inferred sensor provenance, while `automate-live-runtime-verification` owns fresh scratch repositories, runtime adapters, JSONL capture, redaction, and `case.json`/`result.json`/`summary.json` live evidence.

Relevant agent-evaluation practice reinforces those boundaries. SWE-bench uses isolated reproducible environments and test-derived outcomes; Terminal-Bench separates task instructions, an executable test, and an oracle solution; Anthropic's agent-eval guidance distinguishes tasks, repeated trials, graders, traces, and environment outcomes, recommends deterministic graders when possible, and reports consistency separately from one-success metrics. Sources: [SWE-bench](https://github.com/SWE-bench/SWE-bench), [Terminal-Bench](https://github.com/laude-institute/terminal-bench), and [Demystifying evals for AI agents](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents).

The benchmark must measure the context artifact, not simultaneously benchmark onboarding generation. Agent runtimes are authenticated, nondeterministic, and not uniformly container-friendly, so live execution remains explicit and records host/runtime identity rather than claiming host-independent equivalence.

## Goals / Non-Goals

**Goals:**

- Reuse live-runtime isolation and trace capture while giving benchmark tasks, conditions, graders, and aggregation one clear owner.
- Freeze the experiment before live trials so conditions, graders, repetitions, and exclusions cannot move after results are seen.
- Make trial verdicts recomputable from objective evidence and make missing evidence fail closed.
- Compare quality and cost without reducing both to a headline score.

**Non-Goals:**

- Benchmark onboarding generation interviews, rank foundation models, or create a hosted leaderboard.
- Require Docker where supported agent CLIs or credentials cannot run faithfully inside it.
- Build a plug-in grader framework, statistical package, or general agent-evaluation SDK.
- Add inferential judges to the initial maintained suite when deterministic outcomes suffice.

## Decisions

### Extend the live harness with a benchmark-owned manifest and runner

Place benchmark-owned task, condition, experiment, grading, and reporting data under one `benchmarks/agent-outcomes/` tree. Reuse the standard-library process, isolation, runtime-adapter, event-capture, redaction, and evidence primitives from `tests/live/` once `automate-live-runtime-verification` supplies them. A thin benchmark command expands an experiment manifest into live cases, invokes those primitives, runs benchmark graders, and aggregates results. It does not duplicate runtime launchers or hook collectors.

The normal Bash suite runs only deterministic manifest, materialization, grader, aggregation, and fake-runtime contract tests. Live model execution has a separate explicit command and optional cost-bearing workflow.

If the live harness is not available when implementation starts, benchmark runtime work waits for or lands with the shared contract; it must not create a second temporary-repository or JSONL subsystem. Mutation fixtures are referenced through stable scenario identities when suitable, not copied into a competing harmful-context corpus.

Alternative considered: adopt an external evaluation framework. Rejected because the needed behavior is a small extension of the already planned harness, current repository policy avoids dependencies, and a framework would not remove runtime-specific onboarding materialization or graders.

### Treat each benchmark task as a sealed scenario pack

Each task pack contains a manifest, a clean repository fixture or deterministic constructor, an agent-facing instruction, context source material, and one or more objective graders. The manifest declares category, expected outcome, applicable runtimes and conditions, permitted tools and permissions, budgets, timeout, and evidence fields. Graders inspect final repository state, test results, command records, or invariant checks; they never parse the agent's success claim to decide task success. Graders execute outside the agent-visible repository and tool boundary during a trial, but their versioned definitions are retained and published with reportable evidence so another reviewer can regrade without model access.

Start with one reviewable task for each required behavior category. Prefer small synthetic repositories whose hidden grader expresses one real failure mode from AIBoarding's documented contract or mutation corpus. Add another task only when it exercises materially different behavior; task count is not evidence quality. Validate reference success and an intentionally wrong solution before admitting a task.

Nested/local-instruction tasks run only on runtimes whose loading precedence is externally verified. Their condition bundle explicitly controls every applicable root and nested instruction file, preventing an undeclared local file from leaking the answer.

Alternative considered: reuse this repository as every task fixture. Rejected because agent edits could disturb maintainer state, tasks would overfit one codebase, and context conditions would be harder to isolate.

### Freeze context bundles before trials

Materialize every condition as an immutable bundle of instruction files plus a provenance record containing source revision, AIBoarding skill revision, compression level, source-content hash, output hash, byte and measured-token counts when available, and any compression receipt. Trial execution only installs the selected frozen bundle into a fresh task repository; it never runs generation or compression inside the measured trial.

The maintained profile uses these condition identities:

- `none`: no project onboarding files in the applicable instruction chain;
- `manual-minimal`: independently hand-written minimal guidance frozen before trials;
- `aiboarding-off`: current uncompressed AIBoarding output;
- `aiboarding-lite`, `aiboarding-full`, and `aiboarding-ultra`: applicable supported compression outputs;
- `stale`: a valid bundle from a declared older task-repository revision;
- `contradictory`: a valid bundle with one declared realistic contradiction, preferably referenced from the mutation corpus;
- `truncate-<budget>`: mechanical prefix truncation of the effective uncompressed AIBoarding instruction payload at each compared compressed bundle's declared size budget.

Size-matched truncation makes the compression comparison about selection and rewriting under the same budget instead of comparing arbitrary lengths. The condition uses the runtime's declared effective load order and cuts at the largest valid UTF-8 boundary not exceeding the byte budget, without semantic or syntax repair. It records how the effective prefix maps back to delivered files and is inapplicable when the runtime's delivery boundary cannot be reproduced. Where a runtime tokenizer is measurable, report its count; bundle construction still uses the stable byte boundary so another machine can reproduce the artifact without a provider tokenizer.

Alternative considered: regenerate AIBoarding output before every trial. Rejected because generation variance would confound the context effect and make the tested inputs irreproducible.

### Predeclare controlled experiments and execute randomized blocks

An experiment manifest freezes source revision, task and condition sets, requested runtime/model identifiers and observed immutable versions where exposed, agent-harness versions, permissions, tools, budgets, timeouts, grader revisions, trial count, ordering seed, retry policy, exclusions, and aggregation version before live execution. An unavailable immutable provider version is recorded as a limitation rather than inferred; any detected version drift creates a distinct experiment identity. The runner executes one fresh session and scratch repository per task-condition-trial cell. It randomizes condition order within task-and-repetition blocks to reduce provider or time drift while retaining stable run identities.

Only declared transient infrastructure failures may be retried. Every attempt remains in evidence; a retry cannot erase a valid agent failure. Human intervention defaults to forbidden. A profile that allows intervention records it and aggregates separately. Any controlled-variable change creates a new experiment identity rather than extending the old matrix.

A deterministic pilot validates task solvability, graders, budgets, and runtime plumbing. A small live pilot may set the final repeated-trial count, but its results are labeled pilot and excluded from the frozen benchmark report. This avoids choosing repetitions or task edits after seeing reportable outcomes.

Alternative considered: run every condition sequentially in a fixed order. Rejected because provider and runtime drift could align with condition order and masquerade as an onboarding effect.

### Reuse the live evidence envelope and add benchmark-specific facts

Each trial keeps the live harness's case metadata, sanitized raw streams, runtime events, collector records, process status, and result. The benchmark result adds task revision, condition bundle identity, controlled-variable fingerprint, final diff or tree hash, grader results, completion-claim detection, command and tool-call classifications, retries, intervention, measured usage, and decisive evidence references. Completion claims and invalid commands use predeclared deterministic classifiers over retained runtime events and task-local command rules. If a runtime does not expose evidence sufficient for either classifier, that metric is `unavailable` with a reason rather than guessed. Missing measurable data is likewise `unavailable`, never zero.

Store local evidence and grader definitions outside the agent-visible fixture repository. The report command consumes only recorded evidence and can be rerun without model access. Publication checks in the frozen manifest, aggregate JSON, Markdown report, condition/task and grader definitions, artifact inventory, and SHA-256 hashes. Sanitized trial evidence is published as a compressed bundle or durable release artifact referenced by those hashes. Credentials, auth homes, and unrestricted environment dumps are never retained; grader source is retained for independent inspection but published only after all reportable trials in the frozen experiment are complete.

Alternative considered: commit every raw transcript. Rejected because traces can be large and may contain provider metadata; a hashed sanitized evidence bundle preserves inspection without permanently bloating the repository.

### Keep grading declarative and objective-first

Use small task-local grader commands returning a normalized JSON result with grader identity, provenance (`computed` or `inferred`), assertions, verdict, and evidence references. The runner treats timeout, malformed output, or missing evidence as incomplete. Existing tests, preservation checks, budget checks, and mutation sensors are invoked directly where they own the invariant.

The initial maintained suite uses computed graders only. If a future task genuinely requires inference, its manifest names the criterion and protocol, emits a separate inferred record with runtime/model identity, and cannot override computed failure. No generic model-judge adapter is added until such a task exists.

Alternative considered: one LLM judge over each transcript. Rejected because coding outcomes, commands, and invariants are mechanically testable and using the tested agent system as authority would weaken falsifiability.

### Report raw metrics and modest uncertainty, not one composite score

Aggregate binary outcomes as counts and rates with Wilson 95% intervals; report continuous usage and elapsed metrics as count, median, and interquartile range. Always retain per-task results so a condition cannot hide a guardrail regression behind easier command-discovery wins. Report quality and cost columns side by side, plus paired condition differences where the frozen matrix contains comparable cells. Do not compute a quality-cost composite or significance claim.

False completion means a detectable completion claim paired with objective task failure. Architecture/guardrail violations and invalid command attempts remain independent metrics even when the final task passes. Report unavailable observations and incomplete cells in denominators explicitly. Interpretation follows measured tables and states the maintained-task, runtime, and model boundary.

Alternative considered: rank conditions by a weighted aggregate. Rejected because weights would encode product preferences, conceal trade-offs, and invite favorable headline tuning.

## Risks / Trade-offs

- [Small synthetic tasks overstate external validity] -> Derive each from documented or observed repository failure modes, keep task-level results visible, and state the corpus boundary.
- [Tasks leak their answer outside the tested context] -> Audit prompts and fixtures, control the full instruction chain, disable undeclared tools, and run `none` negative controls.
- [Provider drift survives variable recording or an alias hides the immutable model version] -> Randomize blocks, keep trials temporally close, record requested and observed runtime/model identities, disclose unavailable provider versions, and never pool detected distinct fingerprints.
- [AIBoarding output is tailored to benchmark tasks] -> Freeze source context and task manifests before reportable trials, retain manual and harmful controls, and publish all cells.
- [Hidden graders reward one implementation] -> Grade outcomes and invariants, validate an independent reference solution, and avoid exact patch matching.
- [Inference becomes convenient rather than necessary] -> Keep initial suite computed-only and require a task-specific declared gap before adding an inferred record.
- [Evidence publication leaks sensitive data] -> Use scratch credentials only at invocation, allowlist retained fields, sanitize streams, inspect the publish inventory, and hash the final bundle.
- [Pending harness or mutation contracts change] -> Consume their final result identities at apply time and avoid interim duplicate formats.

## Migration Plan

1. Reconcile the final live-runtime and mutation evidence contracts; add benchmark-owned schemas and deterministic contract tests without launching a model.
2. Add the six-category task corpus, reference and wrong-solution grader checks, frozen condition materialization, and size-matched truncation fixtures.
3. Add the thin benchmark runner over shared live isolation, then prove fresh-state, controlled-variable, retry, incomplete-evidence, and fake-runtime behavior.
4. Add aggregation and exact report fixtures covering favorable, unfavorable, variable, missing, and inferred-labeled evidence.
5. Run and review pilots, freeze the reportable experiment manifest, execute repeated trials, inspect the sanitized evidence inventory, and publish the full matrix plus hashed evidence bundle.
6. Update the roadmap and verification coverage map only after published evidence identifies exact runtime, model, source revision, and experiment identity.

Rollback removes benchmark-only manifests, fixtures, runner integration, reports, and workflows. Shared live-runtime primitives, mutation evidence, production onboarding formats, and ordinary tests remain unchanged; published evidence stays immutable and may be marked superseded rather than rewritten.

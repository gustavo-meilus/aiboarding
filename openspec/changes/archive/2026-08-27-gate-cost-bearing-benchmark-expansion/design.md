## Context

See `proposal.md` for motivation and `specs/agent-outcome-benchmarking/spec.md` for behavior. The existing implementation already validates diagnostic/comparison declarations, regrades retained evidence, writes a diagnostic gate result, and requires explicit expansion. Its maintained diagnostic is the historical 12-cell v7 profile; this revision reduces future runtime viability testing without changing that retained experiment.

## Goals / Non-Goals

**Goals:**

- Reuse the existing profile, runner, retained-evidence classifier, grader, diagnostic gate, and expansion command.
- Prove the real Codex/onboarding/evidence/grading path with one bounded live call.
- Keep historical evidence readable and comparisons separately deliberate.

**Non-Goals:**

- Add a sentinel task, second gate, retry controller, cost estimator, token budget, statistical planner, output schema, or orchestration service.
- Claim that a Luna canary establishes another model's behavior or that one cell provides comparative evidence.
- Change graders, task semantics, condition semantics, aggregation, packaging, or reporting completeness.

## Decisions

### Add a new one-cell maintained diagnostic profile

Create a new frozen diagnostic identity containing `command-discovery` x `aiboarding-full` x one repetition, with `max_live_trials` equal to one. Do not edit or re-fingerprint v7: it remains historical diagnostic/unpublished evidence. Comparisons that use the maintained workflow must reference the new canary identity and its viable gate result.

`command-discovery` is the cheapest existing suitable task: its deterministic grader checks the documented command record and objective outcome, while its fixture exercises onboarding delivery, the Codex execution path, evidence retention, and local regrading. A new sentinel would duplicate this coverage.

### Freeze the smallest sufficient Codex runtime

Pin the canary to `gpt-5.6-luna` with low reasoning effort, disabled web search, ignored unrelated user configuration, an ephemeral session, JSONL output, one attempt, and a bounded timeout. Use `workspace-write`, because the reused task must write `verification.log` and `outcome`; read-only authority cannot satisfy its existing evidence contract.

Record these values in the profile/controlled identity and translate them through the existing Codex command builder. Keep JSONL because it is the evidence surface, not the main cost driver. Do not add output schemas or token-budget machinery.

### Preserve the existing evidence and expansion gates

The current retained-evidence assessment remains authoritative: complete objective pass and fail make the one cell viable, while incomplete evidence blocks expansion. The diagnostic command exits after writing its evidence and gate result. Starting a comparison remains a distinct explicit invocation that verifies the new diagnostic fingerprint.

### Keep prompt inspection optional

Document `codex debug prompt-input` only as an optional preflight/troubleshooting aid for checking model-visible onboarding. Because it is experimental, deterministic tests and gate correctness do not invoke or depend on it.

## Risks / Trade-offs

- [One cell cannot support an outcome comparison] -> Label it diagnostic/unpublished and require a separately designed comparison for comparative claims.
- [Luna viability is mistaken for Sol behavior] -> State that the canary validates plumbing only and freeze the model required by any later claim in that comparison's identity.
- [Ignoring user configuration removes required authentication] -> Ignore configuration while continuing to use the existing Codex authentication location supported by the CLI.
- [The reused task needs writes] -> Use workspace-write as the least sufficient sandbox and retain fixture isolation.
- [Historical comparison links still reference v7] -> Preserve their identities; update only future maintained comparison selection to reference the new diagnostic.

## Migration Plan

1. Add and validate the new one-cell diagnostic profile without modifying historical manifests or evidence.
2. Apply the frozen Codex runtime controls through the existing runner command path.
3. Point future maintained comparison expansion at the new diagnostic identity.
4. Update deterministic tests and the manual verification protocol; do not run authenticated Codex from tests.
5. Roll back future use by selecting the prior maintained profile; retained formats and historical identities remain unchanged.

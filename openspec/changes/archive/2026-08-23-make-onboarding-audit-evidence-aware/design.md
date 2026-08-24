## Context

See `proposal.md` for motivation and `specs/onboarding-audit-evidence/spec.md` for observable behavior. Today `skills/audit-agent-onboarding/SKILL.md` defines twelve checks but only delegates size validation to executable tooling. The remaining checks are described as model actions even when some repository states can be proved mechanically. Existing tools are portable Bash scripts copied from `templates/tools/`, with exit codes and shell fixture tests.

## Goals / Non-Goals

**Goals:**

- Put deterministic checks in one portable command that can run both directly and from the audit skill.
- Reuse `check-size-budget` rather than duplicate its thresholds or counting rules.
- Give deterministic output a stable finding shape suitable for direct report inclusion.
- Constrain computed command findings to cases with authoritative, mechanically inspectable evidence.

**Non-Goals:**

- Converting heuristic text-quality judgments into regex-based pseudo-proof.
- Building a general Markdown parser, secret scanner, or universal shell parser.
- Changing remediation ownership or allowing the audit to write files.

## Decisions

### Add one deterministic audit command

Add one Bash command under `templates/tools/` and install it beside existing AIBoarding tools. It accepts a repository root, discovers the audit target set, delegates per-file limits to `check-size-budget`, computes nested `AGENTS.md` chains, checks wrapper structure, and resolves only supported command-reference forms.

The command emits one line per finding with stable fields for severity, literal provenance `computed`, category, location, and message. Exit status is `0` when no computed `FAIL` exists, `1` when at least one computed `FAIL` exists, and `2` for usage or operational errors. WARN findings therefore preserve current non-failing size-budget behavior.

Alternative considered: separate executable per check. Rejected because discovery, output formatting, exit aggregation, and fixture setup would be duplicated. `check-size-budget` remains separate because it already exists and is reused by the new command.

### Treat command resolution as a conservative allowlist

Computed command failures cover only syntax whose target has an authoritative resolver available to the command: explicit repository-relative paths, explicit package-manager script invocations backed by a local manifest, literal Make/Just targets backed by their files, and executable lookups where the referenced environment is the environment being audited. Each resolver must distinguish “target absent” from “cannot establish.” Unsupported or ambiguous command-like text is left to semantic review.

Alternative considered: extract every backticked span and run or broadly parse it. Rejected because backticks also hold symbols and examples, command execution would violate read-only safety, and shell grammar cannot be validated portably with a small dependency-free tool.

### Use a strict evidence classification for all current checks

| Existing audit category | Classification | Boundary |
| --- | --- | --- |
| Size budget | Computed | Existing line/byte thresholds and strict cap are directly measurable. |
| Codex-cap chain | Computed | File discovery, ancestry, byte totals, and threshold comparison are mechanical. |
| Duplication | Inferred | Whether text restates imported or README content meaningfully is semantic; exact-copy detection may be added later only as a distinct computed subcheck. |
| Contradictions | Inferred | Scope, precedence, and intent require interpretation unless a future rule proves a narrower contradiction. |
| Stale commands | Mixed | Supported unambiguous references are computed; ambiguous references and context-dependent validity are inferred. |
| Vague commands | Inferred | Determining whether prose provides enough executable guidance requires context. |
| Missing sections | Inferred | Required guidance may exist under different headings; literal heading absence is only a sensor, not proof of missing content. |
| Skill leakage | Inferred | Procedural ownership and the roughly 15-line heuristic require judgment. |
| Lint leakage | Inferred | Whether guidance belongs in formatter configuration depends on project architecture. |
| Rules extraction candidates | Inferred | Length, domain scope, and correct agent visibility require interpretation. |
| Unsafe content | Inferred | Secret-like patterns and confirmation framing are contextual; pattern matches alone do not prove a live secret or unsafe instruction. |
| Wrapper integrity | Computed | Required exact import and marker-fence structure are syntactic invariants. |

This table is copied into the audit skill as its operating contract. A category may be mixed only when computed and inferred subchecks are reported separately; the model never upgrades its own judgment to computed.

### Orchestrate two phases, render one report

The skill first runs the deterministic command and captures findings plus exit status. Exit `2` stops the audit with a tooling error rather than disguising incomplete validation as a clean result. Otherwise the model reviews only inferred or unresolved portions of the category matrix. It then renders all findings ordered FAIL, WARN, INFO, with both severity and provenance on every line.

Alternative considered: separate computed and inferred report sections. Rejected because severity ordering is existing user behavior; explicit per-finding provenance already preserves the evidence boundary.

### Test through fixtures and exact report examples

Use temporary-repository fixtures in one focused shell test, following current `tests/tools/` patterns. Cover clean and invalid wrapper states, soft and strict size limits, multiple nested chains, supported valid and missing command targets, unsupported command text, and all three exit-status classes. Add a checked mixed-report example to the audit skill or test fixture so formatting cannot regress into implicit provenance.

## Risks / Trade-offs

- [Bash portability differs across platforms] Mitigation: stay within conventions already used by AIBoarding tools and test on the project's supported shell path.
- [Command resolvers can produce false certainty when environment assumptions differ] Mitigation: require an authoritative applicable resolver; otherwise defer to inferred review.
- [Line-oriented output can be awkward for messages containing delimiters] Mitigation: choose a fixed delimiter and sanitize free text; exit status remains the machine success/failure contract.
- [Audit may report fewer computed stale commands than users expect] Mitigation: accuracy outranks coverage; semantic review retains unresolved cases.

## Migration Plan

1. Add the deterministic command and fixtures without changing existing audit behavior.
2. Update tool installation and manifest checks so newly generated onboarding setups receive it.
3. Update the audit skill classification, two-phase orchestration, and evidence-aware report format.
4. Run focused tool fixtures, plugin/manifest checks, and strict OpenSpec validation.

Rollback removes the new command from installation and restores the prior skill instructions; no repository data or onboarding content migration is required.

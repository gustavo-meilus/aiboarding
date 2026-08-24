## Context

See `proposal.md` for motivation and `specs/codex-instruction-budget-validation/spec.md` for observable behavior. Current `check-size-budget` measures one file against AIBoarding's 220-line and 24000-byte recommendations plus a `strict_max_bytes` value defaulted to 32768. The audit skill separately instructs the model to sum nested `AGENTS.md` files, while the pending `make-onboarding-audit-evidence-aware` change plans one deterministic audit command but currently specifies a generic leaf-to-root `AGENTS.md` sum.

Official Codex documentation defines a more precise project chain: walk from project root to working directory, choose at most one non-empty file per directory in `AGENTS.override.md`, `AGENTS.md`, then configured fallback order, concatenate root first, and stop at `project_doc_max_bytes`, default 32 KiB. Global Codex-home guidance is a separate scope and repository validation cannot reliably infer a user's full merged runtime configuration.

## Goals / Non-Goals

**Goals:**

- Match documented Codex project discovery for every instruction-bearing repository endpoint.
- Keep one portable, deterministic source of chain findings for direct validation and audit orchestration.
- Make byte totals, selected files, endpoint, runtime limit, and configuration source reproducible.
- Preserve existing AIBoarding soft limits and existing managed-repository configuration.

**Non-Goals:**

- Reproduce model tokenization or measure global Codex-home instructions.
- Discover every user, system, profile, trust, or command-line Codex configuration layer.
- Restructure nested onboarding content or add a second audit validator.

## Decisions

### Extend the pending deterministic audit command with one chain engine

Implement chain discovery as a reusable mode or internal section of the deterministic audit command planned by `make-onboarding-audit-evidence-aware`; if that change has not landed when apply begins, introduce the same single command and reconcile the pending artifact before merge. `check-size-budget` remains the fast per-file sensor and delegates no repository traversal.

Alternative considered: add a standalone chain-only script. Rejected because audit target discovery, config parsing, finding formatting, exit aggregation, installation, and fixtures would be duplicated.

### Evaluate only instruction-bearing endpoints

Walk the repository once, skipping only version-control metadata and documented transient directories, and record directories containing a supported non-empty candidate. For each such directory plus the repository root, derive the selected chain from its ancestors. Descendants without another instruction file inherit an identical chain, so enumerating every repository directory adds cost without new results. Deduplicate identical chains while retaining the first affected endpoint used in findings. Drift `ignored_paths` do not alter Codex instruction discovery.

Alternative considered: recursively sum every discovered `AGENTS.md`. Rejected because siblings never coexist in one Codex chain and filename precedence can make discovered files inactive.

### Mirror documented filename selection, with explicit portable inputs

Default candidates are `AGENTS.override.md` then `AGENTS.md`; append `project_doc_fallback_filenames` from managed AIBoarding configuration when present. Treat only non-empty regular files as candidates and select the first candidate in precedence order per directory. The repository root is supplied explicitly to the tool instead of reimplementing Codex project-root marker resolution.

Alternative considered: infer fallback names and project root from the operator's Codex home. Rejected because that is machine-specific, may not match the runtime profile, and makes repository fixtures non-deterministic.

### Separate soft recommendations from runtime configuration

Keep existing `max_agents_md_lines` and `max_agents_md_bytes` as AIBoarding's soft recommendations. Add the explicit runtime name `codex_project_doc_max_bytes` and continue accepting `strict_max_bytes` as its legacy alias. Resolution order is explicit command input, `codex_project_doc_max_bytes`, legacy `strict_max_bytes`, then 32768. Findings always label the winning source. Existing configs need no immediate rewrite; generated configs use the explicit Codex name.

Alternative considered: read `.codex/config.toml` as automatically effective. Rejected because Codex merges user, project, profile, trust, and command-line layers; a repository-local parser could report false authority. Operators can pass the effective value explicitly or mirror it in managed config.

### Count selected file content bytes and report load order

Use the same byte-count primitive as `check-size-budget` for each selected file, sum raw content bytes, and compare the sum with the runtime limit. Output includes endpoint, root-to-leaf paths, per-file bytes, cumulative bytes, limit, and limit source. No token estimate is emitted. A total greater than the limit is a computed `FAIL`; incomplete discovery or invalid numeric configuration is an operational error.

Alternative considered: include estimated prompt separators or tokens. Rejected because `project_doc_max_bytes` governs document bytes and exact tokenization is outside scope.

### Make validation claims compositional

Audit runs per-file checks for recommendation findings and chain validation for runtime findings. Create and update workflow gates require both. Per-file success text changes from "within Codex cap" to "local file within configured sensor" unless the chain result is also available.

## Risks / Trade-offs

- [Codex loading semantics change] Mitigation: keep filename order, default limit, and byte rules in focused fixtures tied to the official documentation URL and update them together.
- [Repository traversal enters generated or vendored trees] Mitigation: skip only documented transient roots and verify exclusions do not reuse drift-only ignores or hide supported committed instruction files.
- [Legacy `strict_max_bytes` may have been treated as an AIBoarding policy rather than runtime mirror] Mitigation: preserve its behavior as a deprecated alias and label its source; new configs use the explicit Codex name.
- [Pending audit-evidence work lands first] Mitigation: extend its command and tests; do not create parallel tooling.

## Migration Plan

1. Add explicit config keys while retaining legacy aliases and unchanged default behavior.
2. Add Codex-semantic chain discovery and the five focused fixture shapes to the single deterministic audit command.
3. Route audit, create, update, and any shared blocking validation through that result; revise per-file claims.
4. Run focused fixtures, plugin/template checks, full regression tests, and strict OpenSpec validation.

Rollback restores prior skill orchestration and generated config keys while leaving legacy aliases accepted; no onboarding documents or repository data require migration.

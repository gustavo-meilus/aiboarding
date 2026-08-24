## Context

See `proposal.md` for motivation and `specs/onboarding-verification-evidence/spec.md` for behavior. Current hooks read `.aiboarding/state.json` with `_lib:json_get`, a line scanner that requires pretty-printed JSON with one top-level key per line and returns the first matching scalar. `drift-check` reads only `last_synced_commit`; the audit skill reads legacy compression `receipts`; create, migrate, update, and compression skills write the state file. The modern drift classifier already treats `.aiboarding/*` as bookkeeping.

Several pending changes define evidence producers this change must integrate rather than duplicate: `harden-onboarding-drift-classification` owns deterministic path disposition, `make-onboarding-audit-evidence-aware` owns computed/inferred audit findings, `gate-aiboarding-changes-on-executable-verification` owns mutation gates, and `automate-live-runtime-verification` owns raw live case results and `summary.json`.

## Goals / Non-Goals

**Goals:**

- Give significant lifecycle decisions one compact, durable, machine-readable evidence contract.
- Make pointer advancement explainable and ordered after required evidence persistence.
- Keep retries idempotent, interrupted writes non-destructive, and mixed-version operation safe.
- Reuse existing classifier, validator, compression, and runtime result contracts.

**Non-Goals:**

- Replace raw test artifacts, build an event service, or retain every hook invocation.
- Parse or store prompts, model reasoning, credentials, environment dumps, or full runtime streams.
- Remove legacy compression receipts during this change.
- Make evidence files part of native onboarding loading.

## Decisions

### Store immutable records outside `state.json`

Use one pretty-printed JSON file per logical event under `.aiboarding/evidence/v1/`. Each record contains top-level `schema_version`, `record_id`, `type`, `outcome`, `repository`, optional `subject`, compact `checks`, and type-specific allowlisted `details`. Repository metadata carries a safe identity plus `head` and, for range decisions, `base`. The identity is a credential-stripped canonical remote host/path when available, otherwise the repository root commit identity; absolute local paths are never recorded. Runtime records add only runtime name, version, protocol identity, verdict, and hashes or relative references to decisive sanitized artifacts.

`record_id` is a stable semantic identity such as the verification type plus source range, protocol, and subject. A small installed evidence writer maps that identity to a Git object hash for the filename, writes a temporary file in the destination directory, and renames it into place. Repeating an identical record succeeds without another file; the same identity with different content fails visibly. The writer never opens `state.json`.

Per-record files avoid partial JSON Lines, duplicate append retries, whole-log rewrites, and writer contention. The expected volume is low because only lifecycle decisions and verification summaries are recorded. Records are committed with other `.aiboarding` lifecycle files unless a caller explicitly retains runtime evidence through its existing external artifact policy.

Alternative considered: append JSON Lines to `state.json`. Rejected because it turns canonical operational state into history, breaks the one-top-level-key-per-line assumption, and grows the hook-read file indefinitely.

Alternative considered: a separate `.aiboarding/evidence.jsonl`. Rejected because safe idempotent append and recovery from an interrupted final line require more locking, deduplication, and rewrite behavior than immutable event files.

Alternative considered: add `last_evidence_id` to `state.json`. Rejected because matching evidence `repository.head` to `last_synced_commit` already provides the needed association, while a second pointer creates mixed-version rewrite and dangling-reference cases.

### Keep the record schema narrow and producer-owned details allowlisted

The common envelope is fixed and versioned. Each supported type has a small details contract:

- `drift-classification`: final disposition, compact path categories or matched signals, and affected or revalidated sections;
- `onboarding-validation`: subject paths or Git blob identities and validator name/result pairs;
- `compression-verification`: subject, level, before/after byte and line counts, optional labeled token estimate, content identities, and preservation/size results;
- `live-runtime-verification`: runtime/version, protocol or case ID, verdict, source commit, and decisive sanitized result identities.

Writers construct records from known result fields, never by copying arbitrary stdout, stderr, environment, prompt, or transcript content. Unknown fields are rejected by focused contract validation instead of being retained “for debugging.” Failure messages keep short codes and validator identities; raw details remain in their existing transient or CI artifact locations.

Alternative considered: a generic `metadata` map. Rejected because it invites secret and log retention, makes consumers type-guess, and weakens schema evolution.

### Sequence required evidence before state advancement

For no-op and relevant-update flows, the owner snapshots `base` and `HEAD`, classifies or updates, runs required validators, constructs and persists the evidence record, re-reads `HEAD`, then advances `last_synced_commit` only if it still equals the evidenced head. State rewriting preserves every existing key and the one-top-level-key-per-line format. Evidence write failure or head mismatch blocks advancement and is reported.

For failed validation, canonical state remains unchanged. Recording the failure is best effort because preserving history cannot repair the failed gate; if that write also fails, both failures are reported. For completed runtime verification, failure to import the optional lifecycle history record produces an explicit degraded recording result but never changes onboarding state or the authoritative runtime verdict.

This order cannot atomically commit two files, but it fails safely: a successful evidence write followed by state-write failure leaves an explainable orphan record and an old pointer, while the reverse ordering is forbidden. Retry reuses the same record identity.

Alternative considered: advance state and record evidence afterward. Rejected because an evidence failure would leave an unexplained pointer, the exact failure this change addresses.

### Reuse existing drift suppression

No new drift rule is needed. Modern `drift-check` already hardcodes `.aiboarding/*` as ignored bookkeeping before reading project-configured ignores, so `.aiboarding/evidence/v1/*` cannot trigger onboarding drift. Add a focused evidence-only range fixture to preserve this invariant.

Alternative considered: add evidence paths to `config.json:ignored_paths`. Rejected because users can edit that list and the managed lifecycle namespace is already the responsible invariant.

### Preserve legacy state and dual-write compression during compatibility

Do not change `state.json` schema or `_lib:json_get`. Existing repositories may lack evidence entirely, and new readers treat that as “no historical evidence,” not malformed operational state. New compression runs write the new evidence record and continue appending the current receipt shape to `state.json` so `audit-agent-onboarding --stats` and older skills remain functional. Existing receipts are preserved in place; optional migration may copy them into evidence with stable identities but never deletes or rewrites them.

Create and migrate workflows install the evidence writer and create the evidence directory lazily on first record. Rollback stops new evidence writes and removes the helper from future installations; preserved `state.json` remains authoritative and historical evidence files can remain inert. Removing receipts is a later contraction requiring separate authorization and consumer proof.

Alternative considered: move all receipts immediately and update the audit reader. Rejected because mixed versions would lose stats and rollback would require reconstructing state.

### Integrate summaries, not overlapping engines

The drift update workflow records the output contract supplied by `harden-onboarding-drift-classification`; it does not add another classifier. Onboarding update/create records validator outcomes supplied by the executable-verification and audit changes; it does not create a second validation suite. Standalone audit remains read-only: its machine-readable result is persisted only when a state-owning lifecycle workflow imports it. Compression keeps using `check-preservation` and `check-size-budget`. Live-runtime integration imports the sanitized `result.json` or `summary.json` contract from `automate-live-runtime-verification` and references raw evidence by hash or relative artifact identity rather than copying it.

If those pending changes are not yet applied, implementation adds producer integration only for contracts that exist and leaves explicit task dependencies for the others; it must not invent incompatible interim formats.

## Risks / Trade-offs

- [Many small committed files accumulate] Mitigation: record only significant decisions and compact summaries; add retention only after measured repository growth justifies it.
- [Agent-authored JSON is malformed] Mitigation: validate required envelope fields and JSON before atomic installation; failed validation blocks required state advancement.
- [Sensitive text enters a detail field] Mitigation: use per-type allowlists and identifiers/hashes, never arbitrary command output.
- [Pending OpenSpec changes alter producer shapes] Mitigation: consume their declared result contracts and reconcile at apply time rather than copying their implementation.
- [Git `HEAD` moves during an update] Mitigation: compare it again after evidence persistence and before pointer write; stale work cannot advance state.
- [Rollback leaves unused evidence] Mitigation: records are independent and inert; rollback does not delete history or modify canonical state.

## Migration Plan

1. Add the versioned evidence contract, atomic idempotent writer, and fixtures without changing state readers or writers.
2. Add evidence-only drift suppression proof and mixed-version tests with current `state.json`, including absent-evidence operation and preserved receipts.
3. Integrate no-op and relevant-update workflows using evidence-first, head-recheck, state-last sequencing; verify failed record writes leave the pointer unchanged.
4. Integrate create/update validators and compression checks, dual-writing existing receipts during the compatibility window.
5. Integrate compact live-runtime result import after the runtime harness contract is present; retain its raw artifacts under its existing policy.
6. Exercise no-op, relevant update, compression pass/fail, failed onboarding verification, runtime pass/degraded, retry, rollback, and strict OpenSpec validation.

Rollback disables evidence-aware writes and removes the installed writer from new setups while preserving `state.json`, legacy receipts, onboarding content, and already recorded evidence. No destructive contraction occurs in this change.

# Cost-Bearing Benchmark Gate — Handoff Review

## Status

Implementation is complete: all 7 OpenSpec tasks are checked, strict OpenSpec
validation passes, and a fresh read-only verifier returned `PASS`. No live or
authenticated Codex benchmark was run during this work.

## What problem this solves

A benchmark trial is a full, fresh `codex exec` session in a disposable task
repository, followed by retained-file collection and local regrading. The
maintained full matrix is 6 tasks × 9 conditions × 2 repetitions = 108 such
sessions. The existing v7 smoke matrix is 6 tasks × 2 conditions × 1 repetition
= 12 sessions.

Previously, the package/report path correctly rejected incomplete evidence, but
the runner could start a broad profile before proving that its runtime,
retention, and regrading path worked. The new gate moves that stop point ahead
of the expensive matrix.

## Implemented process

```text
Freeze diagnostic manifest (exact cells + max live trials)
  -> run its explicit live command
  -> retain trial evidence and regrade local snapshots
  -> write diagnostic-gate.json
       incomplete evidence: viable=false; diagnose; stop
       complete objective pass or fail: viable=true
  -> maintainer explicitly invokes comparison with --expand-from gate file
  -> comparison keeps existing incomplete-evidence packaging/report rejection
```

The runner never infers success from agent prose. It only considers a cell
diagnostically complete after the existing retained-evidence contract and local
grader both complete. An objective `fail` is still a complete diagnostic result:
it is a task outcome, not an infrastructure failure.

## Delivered changes

- `benchmark.py` accepts an additive `execution` declaration and validates the
  execution kind, exact declared live-trial ceiling, and comparison diagnostic
  fingerprint.
- `codex-maintained-outcomes-v7-smoke.json` is declared a 12-trial diagnostic.
- `codex-maintained-outcomes-v6.json` is declared a 108-trial comparison that
  accepts the v7 diagnostic fingerprint.
- `pilot.py` reuses retained snapshot regrading to produce
  `diagnostic-gate.json` with `unpublished: true`; it requires
  `--expand-from` with a viable matching gate before a marked comparison starts.
- `docs/VERIFICATION.md` documents diagnostic-first operation and the separate
  expansion command.
- Deterministic tests cover the declared bound, viable complete failure,
  incomplete blocking, and explicit expansion. They do not invoke Codex.

## Current retained v7 result

Offline evaluation of the retained v7 smoke run writes a diagnostic gate with
`viable: false` and seven incomplete cells. This is the intended outcome: its
evidence stays available for diagnosis but cannot start a comparison or support
a publication claim. The change deliberately does not retry or rerun it.

## Validation evidence

- `openspec validate gate-cost-bearing-benchmark-expansion --strict` — passed.
- `bash tests/run.sh` — exited successfully.
- Focused checks passed:
  `test-agent-outcomes-contracts.sh`, `test-agent-outcomes-runner.sh`,
  `test-agent-outcomes-evidence.sh`, `test-agent-outcomes-aggregate.sh`,
  `test-agent-outcomes-package.sh`, `test-agent-outcomes-offline.sh`, and
  `test-agent-outcomes-tasks.sh`.
- Fresh independent review — `PASS`; no defects found.

## Review conclusion

The implementation is intentionally small: existing profiles, planner,
runner isolation, retained snapshots, graders, aggregation, and packaging are
reused. It adds no pricing estimator, retry system, scheduler, database, or
new benchmark framework.

## Next operator actions

1. Review this change and archive it when ready.
2. For a future materially changed Codex path, create/select its bounded frozen
   diagnostic profile and run it explicitly.
3. If its gate is viable, decide separately whether the 108-trial comparison is
   worth the spend. If not, stop; no additional trial is required.
4. If it is incomplete, diagnose retained evidence; do not automatically retry
   or expand.

## Scope notes

- Existing trial and package formats remain unchanged; `execution` is additive.
- Existing unmarked historical profiles remain readable and explicitly usable.
- The current worktree also has unrelated pre-existing changes; this handoff
  covers only `gate-cost-bearing-benchmark-expansion` and its benchmark files.

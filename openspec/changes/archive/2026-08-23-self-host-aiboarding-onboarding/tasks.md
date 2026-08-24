## 1. Bootstrap Managed Onboarding

- [x] 1.1 Use the public `create-agent-onboarding` discovery and synthesis flow to draft root `AGENTS.md`; verify all nine canonical sections exist, every stated command resolves, protected spans survive compression, and `.aiboarding/tools/check-size-budget AGENTS.md` passes.
- [x] 1.2 After the lifecycle approval gate, install the standard `CLAUDE.md`, `.aiboarding/` state/config/hooks/tools, and `.claude/settings.json` entries; verify the wrapper imports `AGENTS.md`, operational state is outside instruction files, installed hook/tool bytes match `templates/`, and each hook event has exactly one managed entry.
- [x] 1.3 Configure authoritative self-host drift inputs without ignoring `README.md`, rerun standard setup, and verify before/after hashes and structural counts show no duplicate file, marker block, hook entry, or state field and no user-owned content changed.

## 2. Add Self-Host Acceptance Coverage

- [x] 2.1 Add a focused `tests/self-host/test-managed-repo.sh` check for the canonical section schema, wrapper integrity, instruction budget, state/config shape, template-copy parity, unique hook wiring, and self-host ignored paths; run the new test directly and verify it passes.
- [x] 2.2 Extend `docs/VERIFICATION.md` with a self-host protocol using only public create, update, audit, and compression workflows; verify it defines repeat-setup, no-op, relevant-drift, loop-suppression, audit, preservation, cleanup, and evidence criteria without replacing fixture protocols.

## 3. Prove Lifecycle Behavior

- [x] 3.1 Run the self-host no-op update protocol in a disposable AIBoarding checkout and verify `AGENTS.md` and `CLAUDE.md` hashes remain identical while only the sync pointer advances.
- [x] 3.2 Run the self-host relevant-drift and onboarding-only range protocols in the disposable checkout; verify the affected onboarding scope is detected and the follow-up bookkeeping range emits no drift nudge.
- [x] 3.3 Run the public audit and compression-preservation checks against the maintained root; verify audit has no unresolved `FAIL`, preservation passes, and canonical guidance remains within budget.
- [x] 3.4 Run `bash tests/run.sh` and verify the existing fixture suite plus new self-host acceptance check pass with no plugin packaging or user-facing lifecycle regression.

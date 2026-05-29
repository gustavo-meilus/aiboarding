# aiboarding — Verification Runbook

These protocols verify the behaviors that the bash test suite structurally cannot reach:
the marketplace install path (2a) and the two live-runtime behaviors (1a PreToolUse[Task]
injection, 1e `update-aiboarding` reasoning branches). Each protocol is **manual** — run it
against a live Claude Code install. Record the outcome in `CHANGELOG.md` / `RELEASE-NOTES.md`
when an item is confirmed.

---

## 2a — Marketplace install (manual)

**Setup:** the repo pushed to `gustavo-meilus/aiboarding` with `.claude-plugin/marketplace.json`
on `main`.

**Steps:**
1. `/plugin marketplace add gustavo-meilus/aiboarding`
2. `/plugin install aiboarding@aiboarding`

**Expected:** marketplace adds without error; plugin installs; `/create-aiboarding` and
`/update-aiboarding` both appear in the skill list; the hook templates are present in the
installed plugin.

**Pass:** both commands succeed and both skills are listed.
**Fail:** any resolution error → re-check `name` / `source` in `marketplace.json` (plugin name
must match `plugin.json`; `source` must point at a dir containing `.claude-plugin/plugin.json`).

---

## 1a — PreToolUse[Task] injection (canary protocol)

**Setup:** a scratch repo with the hooks installed (via the marketplace, or by running
`create-aiboarding` Phase 6) and an `AIBOARDING.md` whose body contains a unique canary string,
e.g. `CANARY-PRETASK-7F3A`.

**Steps:**
1. Start a fresh session (`claude --debug` so hook firing is visible).
2. Spawn a `Task` sub-agent whose prompt asks it to report verbatim any onboarding/aiboarding
   context it received, including any canary token it can see.
3. Inspect the debug output / transcript to confirm the `pre-task` hook fired.

**Expected (pass):** the sub-agent's reply contains `CANARY-PRETASK-7F3A` → `additionalContext`
reaches spawned sub-agents → keep `pre-task` as-is; mark 1a verified.

**Fail:** hook fired but the canary is absent from the sub-agent's view → `additionalContext` is
not delivered → switch to Mechanism B (see decision tree below).

**Inconclusive:** the hook did not fire → fix the matcher/install first; do not conclude anything
about the injection mechanism.

### 1a mechanism design & decision tree (contingent fix — design only)

- **Mechanism A (current, shipped):** `pre-task` emits `hookSpecificOutput.additionalContext`
  carrying the `<aiboarding-context>`-wrapped document. Ignores stdin.
- **Mechanism B (fallback, NOT yet implemented):** `pre-task` reads the incoming PreToolUse JSON
  on stdin, extracts the Task `prompt`, prepends the `<aiboarding-context>` block to it, and emits
  the modified tool input so the document lands literally inside the sub-agent's prompt.

**Risks to weigh before implementing B (not solved now):**
- `pre-task` does not currently parse stdin. B requires parsing the PreToolUse JSON to recover the
  original `prompt`; `_lib` has JSON *escaping* but no *parsing*, and pure-bash JSON extraction is
  brittle.
- The exact input-modification field (`updatedInput` vs. returning a modified `tool_input`) is
  version-dependent. B carries its own verification round — confirm the field against the target CC
  version before relying on it.

```
1a protocol result?
├── PASS (canary visible)        → keep Mechanism A. Mark 1a verified. Done.
├── FAIL (hook fired, no canary) → implement Mechanism B, then re-run the 1a protocol AND a
│                                   field-shape check for B.
│        ├── B PASS               → ship B; update pre-task + tests + docs.
│        └── B FAIL / shape unknown → escalate: document the limitation in known-limitations
│                                     and open a tracking issue.
└── INCONCLUSIVE (hook didn't fire) → fix matcher/install; do not conclude about A or B.
```

---

## 1e — `update-aiboarding` reasoning branches (four cases)

Each case runs in a scratch repo where `create-aiboarding` has already run, so `AIBOARDING.md`
exists with `last_synced_commit` = current `HEAD`.

### Case 1 — No-op branch
**Steps:** make a scope-irrelevant commit (fix a typo in a code comment); run `/update-aiboarding`.
**Pass:** pointer advances to the new `HEAD`; `git diff AIBOARDING.md` shows *only* the
`last_synced_commit` frontmatter line changed; no approval prompt; brief report.

### Case 2 — Targeted-delta branch
**Steps:** make a scope-relevant commit (add a runtime dependency or a new domain concept); run
`/update-aiboarding`.
**Pass:** the scoped grill fires for *only* the affected H1 section; untouched sections are
byte-for-byte identical; caveman compression runs on the re-drafted text; an approval gate precedes
the write; the pointer advances *after* approval.

### Case 3 — Hook-loop sanity
**Steps:** after Case 1 or 2, commit again with no changes (`git commit --allow-empty` or a no-op
edit).
**Pass:** the `post-commit` hook stays silent (in-sync → no nudge).

### Case 4 — Empty-pointer guard
**Steps:** blank out `last_synced_commit` in the frontmatter, then run triage.
**Pass:** triage routes to a full re-validation of all three sections (empty-pointer guard) rather
than taking the silent no-op branch.

# Design Spec: Hardening & Distribution (roadmap items 1a, 1e, 2a)

## Overview
The create → sync → update lifecycle is feature-complete as of v0.1.2. What remains
is **distribution** (making `/plugin install` resolve) and **hardening** (verifying the
two runtime behaviors that the bash test suite structurally cannot reach). This spec
covers three roadmap items as one cohesive unit of work:

| # | Item | Deliverable | Kind |
| :--- | :--- | :--- | :--- |
| **2a** | Marketplace registration | `.claude-plugin/marketplace.json` | buildable artifact |
| **1a** | PreToolUse[Task] injection verification | protocol in `docs/VERIFICATION.md` + mechanism design here | runbook + design-only |
| **1e** | `update-aiboarding` reasoning-branch verification | protocol in `docs/VERIFICATION.md` | runbook |

> **Umbrella:** Shared contracts (document schema, hook layout, drift tracking) live in
> [`2026-05-29-aiboarding-architecture.md`](./2026-05-29-aiboarding-architecture.md).
> This spec touches no hook or skill production code; it adds a static manifest, a
> committed runbook, and the design-only fallback record for 1a.

## Guiding decisions
These were settled during brainstorming and constrain the design:

1. **Protocol doc + contingent fix.** 1a and 1e are *live-runtime verifications* — they
   cannot be self-driven autonomously by the agent. We write precise manual protocols
   now; we write the 1a fallback *code* only if the 1a protocol fails.
2. **1a fallback is design-only.** The `updatedInput` mechanism is documented here as a
   decision tree, not implemented. YAGNI: no code until `additionalContext` is proven to
   fail.
3. **Committed runbook in repo.** Protocols live in `docs/VERIFICATION.md`, committed and
   linked from the README roadmap. This spec references it as the home of the executable
   procedures.

No new automated tests: the manifest is static JSON validated by inspection; the runbook
is manual by nature. The existing bash suite stays green and untouched.

---

## Deliverable 1 — `marketplace.json` (item 2a)

A single-plugin marketplace manifest at `.claude-plugin/marketplace.json`, modeled on the
verified `caveman` plugin's manifest format:

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "aiboarding",
  "description": "Onboard AI agents like fresh engineers: a compressed AIBOARDING.md per repo, auto-injected and kept current via committed hooks.",
  "owner": { "name": "Gustavo Meilus", "url": "https://github.com/gustavo-meilus" },
  "plugins": [
    {
      "name": "aiboarding",
      "description": "Treats AI agents as fresh engineers: generates, injects, and keeps current a compressed AIBOARDING.md per repo.",
      "source": "./",
      "category": "productivity"
    }
  ]
}
```

* **Marketplace name** `aiboarding`, **plugin name** `aiboarding`, so the install commands
  already published in the README and CHANGELOG resolve exactly:
  `/plugin marketplace add gustavo-meilus/aiboarding` → `/plugin install aiboarding@aiboarding`
  (the form is `plugin-name@marketplace-name`).
* `source: "./"` — the plugin lives at the repo root (same repo doubles as the
  marketplace), matching the `caveman` layout.
* The plugin `description` mirrors `plugin.json` for consistency.

**Acceptance:** valid JSON; `name`/`owner`/`plugins` present; plugin `source` resolves to a
directory containing `.claude-plugin/plugin.json`. Live confirmation is part of the runbook
(see 2a verification below).

---

## Deliverable 2 — `docs/VERIFICATION.md` (runbook for items 1a, 1e, 2a)

A committed runbook. Each protocol states **setup → steps → expected output → pass/fail**
so anyone (or a future agent) can run it against a live Claude Code install without
re-deriving the context.

### 2a — marketplace install (manual)
* **Setup:** the repo pushed to `gustavo-meilus/aiboarding` with `marketplace.json` on `main`.
* **Steps:** `/plugin marketplace add gustavo-meilus/aiboarding`; then
  `/plugin install aiboarding@aiboarding`.
* **Expected:** marketplace adds without error; plugin installs; `/create-aiboarding` and
  `/update-aiboarding` skills both appear; the hook templates are present in the installed
  plugin.
* **Pass:** both install commands succeed and both skills are listed. **Fail:** any
  resolution error → re-check `name`/`source` fields.

### 1a — PreToolUse[Task] injection (canary protocol)
* **Setup:** a scratch repo with the hooks installed (via the marketplace, or
  `create-aiboarding` Phase 6) and an `AIBOARDING.md` containing a unique **canary string**
  (e.g. `CANARY-PRETASK-7F3A`).
* **Steps:** in a fresh session, spawn a `Task` sub-agent whose prompt asks it to report
  verbatim any onboarding/aiboarding context it received, including any canary token. Run
  with `claude --debug` (or inspect the transcript) to confirm the `pre-task` hook fired at
  all.
* **Expected (pass):** the sub-agent's reply contains the canary → `additionalContext` is
  delivered to spawned sub-agents → keep `pre-task` as-is.
* **Fail:** hook fired but the canary is absent from the sub-agent's view → `additionalContext`
  is *not* delivered → trigger the fallback (Deliverable 3's decision tree).
* **Inconclusive:** hook did not fire → fix the matcher/install before concluding anything
  about the mechanism.

### 1e — `update-aiboarding` reasoning branches (four cases)
Each case runs in a scratch repo with `create-aiboarding` already run (so `AIBOARDING.md`
exists with `last_synced_commit` = current `HEAD`).

1. **No-op branch.** Make a scope-irrelevant commit (e.g. fix a typo in a code comment).
   Run `/update-aiboarding`.
   * **Pass:** pointer advances to the new `HEAD`; `git diff` on `AIBOARDING.md` shows *only*
     the `last_synced_commit` frontmatter line changed; no approval prompt; brief report.
2. **Targeted-delta branch.** Make a scope-relevant commit (e.g. add a runtime dependency or
   a new domain concept). Run `/update-aiboarding`.
   * **Pass:** the scoped grill fires for *only* the affected H1 section; untouched sections
     are byte-for-byte identical; caveman compression runs on the re-drafted text; an
     approval gate precedes the write; the pointer advances *after* approval.
3. **Hook-loop sanity.** After case 1 or 2, commit again with no changes (`--allow-empty` or a
   no-op edit).
   * **Pass:** the `post-commit` hook stays silent (in-sync, no nudge).
4. **Empty-pointer guard.** Blank out `last_synced_commit` in the frontmatter, then run triage.
   * **Pass:** triage routes to full re-validation of all three sections (per the skill's
     empty-pointer guard) rather than taking the silent no-op branch.

---

## Deliverable 3 — 1a mechanism design & decision tree (design-only)

Recorded here so that, *if* the 1a protocol fails, the fix is unambiguous and no
re-investigation is needed. **No code is written under this spec.**

### Mechanism A — `additionalContext` (current, shipped)
`templates/hooks/pre-task` emits
`hookSpecificOutput.additionalContext` carrying the `<aiboarding-context>`-wrapped document.
This is the assumption the v0.1.0 hook was built on; it ignores stdin entirely.

### Mechanism B — `updatedInput` (fallback, design-only)
If A does not reach the sub-agent, `pre-task` instead **modifies the Task tool's input**:
read the incoming PreToolUse JSON on stdin, extract the Task `prompt`, prepend the
`<aiboarding-context>` block to it, and emit the modified tool input so the document lands
*literally inside* the sub-agent's prompt — independent of whether CC forwards
`additionalContext`.

**Known risks to flag before implementing B (not solved now):**
* `pre-task` currently does **not** parse stdin. B requires reading and parsing the
  PreToolUse JSON payload to recover the original `prompt`. The `_lib` has JSON *escaping*
  but no JSON *parsing*; pure-bash JSON value extraction is fiddly and brittle.
* The exact field name / shape for input modification (`updatedInput` vs. returning a
  modified `tool_input`) is **version-dependent**. B therefore carries *its own*
  verification round — confirm the field against the target CC version before relying on it.

### Decision tree
```
1a protocol result?
├── PASS (canary visible)        → keep Mechanism A. Mark 1a verified. Done.
├── FAIL (hook fired, no canary) → implement Mechanism B (updatedInput), then re-run the
│                                   1a protocol AND a field-shape check for B.
│        ├── B PASS               → ship B; update pre-task + tests + docs.
│        └── B FAIL / shape unknown → escalate: document the limitation in known-limitations
│                                     (sub-agents rely on their own SessionStart, if it fires),
│                                     and open a tracking issue.
└── INCONCLUSIVE (hook didn't fire) → fix matcher/install; do not conclude about A or B.
```

---

## Deliverable 4 — README roadmap linkage
Add a pointer from the README Roadmap (and/or `RELEASE-NOTES.md` Roadmap) to
`docs/VERIFICATION.md` as the home of the executable verification protocols. A link, not a
per-item status table — status tracking stays in the changelog/release notes as items are
confirmed.

---

## Out of scope
* Implementing Mechanism B (deferred until/unless 1a fails — Deliverable 3 is design-only).
* Narrowing the `PostToolUse` matcher to `git commit` (separate hardening item, not in this
  spec).
* Any change to the shipped hooks, skills, or `_lib`.
* Automated tests for the runbook or manifest.

## Acceptance criteria (this spec)
1. `.claude-plugin/marketplace.json` exists, is valid JSON, and follows the schema above.
2. `docs/VERIFICATION.md` exists with all four 1e cases, the 1a canary protocol, and the 2a
   install check — each with setup/steps/expected/pass-fail.
3. The 1a mechanism design + decision tree is captured (in the runbook or this spec) so the
   contingent fix needs no re-investigation.
4. README roadmap links to `docs/VERIFICATION.md`.
5. No production hook/skill code changed; bash suite still green.

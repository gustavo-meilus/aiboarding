# Hardening & Distribution Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the marketplace manifest so `/plugin install aiboarding@aiboarding` resolves, and commit a verification runbook covering the two runtime behaviors (PreToolUse[Task] injection, `update-aiboarding` reasoning branches) the bash suite cannot reach.

**Architecture:** Three documentation/config deliverables, no production hook or skill code. A static `marketplace.json` at the repo root; a committed `docs/VERIFICATION.md` runbook with manual protocols; a README roadmap link. The 1a `updatedInput` fallback is documented as a decision tree only — no code unless the 1a protocol fails.

**Tech Stack:** JSON (Claude Code marketplace schema), Markdown. Validation via Node's `JSON.parse` (or `python -c json.tool`). No test framework involved.

**Spec:** [`docs/superpowers/specs/2026-05-29-hardening-distribution-design.md`](../specs/2026-05-29-hardening-distribution-design.md)

---

## File Structure

| File | Action | Responsibility |
| :--- | :--- | :--- |
| `.claude-plugin/marketplace.json` | Create | Single-plugin marketplace manifest (item 2a) |
| `docs/VERIFICATION.md` | Create | Committed runbook: 2a install check, 1a canary protocol, 1e four cases, 1a decision tree |
| `README.md` | Modify | Roadmap link to the runbook |

There are no automated tests: the manifest is validated by parsing; the runbook is manual by nature; the existing bash suite must remain untouched and green.

---

## Task 1: Marketplace manifest (`marketplace.json`)

**Files:**
- Create: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Create the manifest**

Create `.claude-plugin/marketplace.json` with exactly this content:

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

- [ ] **Step 2: Validate the JSON parses**

Run: `node -e "JSON.parse(require('fs').readFileSync('.claude-plugin/marketplace.json','utf8')); console.log('valid')"`
Expected: prints `valid` (no parse error).

- [ ] **Step 3: Confirm field consistency**

Verify by inspection that `plugins[0].name` is `aiboarding` (matches `.claude-plugin/plugin.json` `name`) and `source` is `"./"`. These two values are what make `/plugin install aiboarding@aiboarding` resolve to this repo's plugin.

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/marketplace.json
git commit -m "feat: add marketplace manifest (item 2a)"
```

---

## Task 2: Verification runbook (`docs/VERIFICATION.md`)

**Files:**
- Create: `docs/VERIFICATION.md`

- [ ] **Step 1: Create the runbook**

Create `docs/VERIFICATION.md` with exactly this content:

```markdown
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
```

- [ ] **Step 2: Validate the markdown renders**

Run: `node -e "const s=require('fs').readFileSync('docs/VERIFICATION.md','utf8'); if(!s.includes('CANARY-PRETASK-7F3A')||!s.includes('Empty-pointer guard')) throw new Error('missing section'); console.log('ok')"`
Expected: prints `ok` (both the 1a canary and the 1e Case 4 are present).

- [ ] **Step 3: Commit**

```bash
git add docs/VERIFICATION.md
git commit -m "docs: add verification runbook (items 1a, 1e, 2a)"
```

---

## Task 3: README roadmap link

**Files:**
- Modify: `README.md` (Roadmap section, around lines 118-124)

- [ ] **Step 1: Add the runbook pointer to the Roadmap**

In `README.md`, the Roadmap section currently reads:

```markdown
The create → sync → update lifecycle is now feature-complete. Remaining work is hardening and distribution:

- **Distribution** — register the marketplace listing so `/plugin install` resolves.
- **Hardening** — live verification that `PreToolUse` `additionalContext` reaches sub-agents (else switch to `updatedInput`); narrow the `PostToolUse` matcher to `git commit` commands; exercise `update-aiboarding`'s grill/synthesis/approval branches against a live runtime.
```

Replace it with:

```markdown
The create → sync → update lifecycle is now feature-complete. Remaining work is hardening and distribution — the manual procedures live in the [verification runbook](./docs/VERIFICATION.md):

- **Distribution** — the marketplace listing (`.claude-plugin/marketplace.json`) is published so `/plugin install aiboarding@aiboarding` resolves; confirm via the runbook's 2a protocol.
- **Hardening** — live verification that `PreToolUse` `additionalContext` reaches sub-agents (else switch to `updatedInput`, per the runbook's 1a decision tree); exercise `update-aiboarding`'s reasoning branches against a live runtime (runbook 1e); narrow the `PostToolUse` matcher to `git commit` commands.
```

- [ ] **Step 2: Verify the link target exists**

Run: `node -e "require('fs').accessSync('docs/VERIFICATION.md'); const r=require('fs').readFileSync('README.md','utf8'); if(!r.includes('docs/VERIFICATION.md')) throw new Error('link missing'); console.log('ok')"`
Expected: prints `ok`.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: link verification runbook from README roadmap"
```

---

## Task 4: Final sanity — bash suite still green

**Files:** none (verification only)

- [ ] **Step 1: Run the existing test suite**

Run: `bash tests/run.sh`
Expected: all five suites pass (no production code was touched, so this confirms the doc/config
changes introduced no regressions).

- [ ] **Step 2: Confirm clean tree**

Run: `git status`
Expected: working tree clean; the three new/modified files are committed.
```

---

## Verification of completed plan (post-execution, manual)

These are the runbook protocols themselves — run them after pushing, against a live install. They are NOT part of task execution (they require a live CC runtime and a pushed marketplace), but completing the plan unblocks them:

- **2a** — add the marketplace + install; confirm both skills appear.
- **1a** — canary protocol; pass → keep `additionalContext`, fail → implement Mechanism B.
- **1e** — the four `update-aiboarding` cases.

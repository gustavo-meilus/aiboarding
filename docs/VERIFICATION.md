# aiboarding — Verification Runbook

These protocols verify the behaviors that the bash test suite structurally cannot
reach: the marketplace install path (2a) and the live-runtime loading/hook behaviors
(3a). Each protocol is **manual** — run it against a live Claude Code install. Record
the outcome in `CHANGELOG.md` / `RELEASE-NOTES.md` when an item is confirmed.

**What the bash suite already covers** (no manual protocol needed): every hook
script's emitted JSON and silence conditions (`tests/hooks/`), the deterministic
tools' guarantees (`tests/tools/`), and the drift-classification matrix — including
the regression tests for issue #1's class (state-only and onboarding-only commit
ranges must not nudge; see `tests/hooks/test-drift-check.sh`).

**Retired protocols:**
- **1a (`PreToolUse[Task]` injection canary)** — retired in v0.4.0. The `pre-task`
  hook and its design-only `updatedInput` Mechanism B are deleted; sub-agent context
  now uses the native `SubagentStart` event (covered by 3a.3 below).
- **1e (`update-aiboarding` reasoning branches)** — superseded. The deterministic
  halves (no-op silence, in-sync silence, empty-pointer nudge) are automated in
  `test-drift-check.sh`; the reasoning halves are re-expressed against the new skills
  in 4a below.

---

## 2a — Marketplace install (manual)

**Setup:** the repo pushed to `gustavo-meilus/aiboarding` with
`.claude-plugin/marketplace.json` on `main`.

**Steps:**
1. `/plugin marketplace add gustavo-meilus/aiboarding`
2. `/plugin install aiboarding@aiboarding`
3. Locally: `claude plugin validate . --strict` must pass before any release.

**Expected:** marketplace adds without error; plugin installs; the five skills
(`create-agent-onboarding`, `update-agent-onboarding`, `migrate-aiboarding`,
`compress-onboarding`, `audit-agent-onboarding`) plus the two deprecated aliases
appear in the skill list (plugin-namespaced as `/aiboarding:<name>`); the hook and
tool templates are present in the installed plugin.

**Pass:** all commands succeed and all skills are listed.
**Fail:** any resolution error → re-check `name`/`source` in `marketplace.json`.

---

## 3a — Live loading & hook-event matrix (manual, canary-based)

**Setup:** a scratch repo where `create-agent-onboarding` has run: `AGENTS.md`
(plant a unique canary string in its body, e.g. `CANARY-AGENTS-7F3A`), `CLAUDE.md`
with `@AGENTS.md`, `.aiboarding/` hooks + state, merged `.claude/settings.json`.
Start sessions with `claude --debug` so hook firing is visible.

### 3a.1 — Native import expansion
Ask a fresh session: "What onboarding context do you have? Quote any canary token."
**Pass:** the reply contains `CANARY-AGENTS-7F3A` (the `@AGENTS.md` import expanded).
**Fail:** canary absent → the whole native-delivery bet is broken for this Claude
Code version; check the import syntax and file locations before anything else.

### 3a.2 — /compact survival
Fill context, run `/compact`, re-ask for the canary.
**Pass:** canary still visible (project-root `CLAUDE.md` re-injected from disk).

### 3a.3 — SubagentStart reminder
Spawn a sub-agent whose prompt asks it to report any onboarding pointer it received.
**Pass:** the sub-agent's reply reflects the `<aiboarding-pointer>` reminder (it
names `AGENTS.md` and the binding sections). The debug output shows the
`subagent-start` hook firing.
**Fail (hook fired, no pointer visible):** document as a known limitation — do NOT
resurrect full-document injection; the fallback is instructing sub-agent prompts
manually.

### 3a.4 — `if`-filter narrowing
With debug output visible, run a non-git Bash command, then a git command.
**Pass:** the `drift-check` process spawns only for the git command.
**Degraded-OK:** if this Claude Code version ignores `if`, the hook must still stay
behaviorally silent on the non-git command (stdin self-gate) — spawn cost only.

### 3a.5 — InstructionsLoaded diagnostics
Set `AIBOARDING_DEBUG=1`, start a session, inspect `.aiboarding/logs/hooks.log`.
**Pass:** the log lists `CLAUDE.md` with `load_reason: session_start` (and any
`.claude/rules/*.md` with their reasons).
**Degraded-OK:** if the event never fires on this version, remove the
`InstructionsLoaded` settings entry; everything else is unaffected.

---

## 4a — Skill reasoning branches (manual)

Each case runs in a scratch repo where `create-agent-onboarding` has already run, so
`AGENTS.md` + `CLAUDE.md` + `.aiboarding/state.json` exist with
`last_synced_commit` = current `HEAD`.

### Case 1 — No-op branch
**Steps:** make a scope-irrelevant commit (typo in a code comment); run
`/update-agent-onboarding`.
**Pass:** `state.json` pointer advances to the new `HEAD`;
`git diff AGENTS.md CLAUDE.md` is **empty** (the hard invariant); no approval
prompt; brief report.

### Case 2 — Targeted-delta branch
**Steps:** make a scope-relevant commit (add a runtime dependency or a new domain
concept); run `/update-agent-onboarding`.
**Pass:** the scoped grill fires for *only* the affected sections; untouched
sections are byte-for-byte identical; compression runs on the re-drafted text with
`check-preservation` clean; an approval gate precedes the write; the pointer
advances *after* approval.

### Case 3 — Hook-loop sanity
**Steps:** after Case 1 or 2, commit the state/doc changes, then run any git command.
**Pass:** the `drift-check` hook stays silent (onboarding-only range → no nudge).

### Case 4 — Repair guard
**Steps:** blank out `last_synced_commit` in `state.json`, then run triage.
**Pass:** triage routes to a full re-validation of all nine sections (never the
silent no-op branch), then reseeds the pointer.

### Case 5 — Migration
**Steps:** in a repo with only a legacy `AIBOARDING.md`, run `/migrate-aiboarding`.
**Pass:** a single preview lists every write before anything happens; after
approval: `AGENTS.md` carries the mapped v1 content, `state.json` carries the old
pointer, `pre-task`/`post-commit` entries and files are gone, and the legacy doc is
archived (or banner-fenced) per the user's choice.

# AIBoarding verification coverage map

`bash tests/run.sh` is deterministic-only and never launches an authenticated
runtime. Run `python3 tests/live/verify_runtime.py --live --strict --runtime codex --case positive --collect-hooks` explicitly
for the one-session Codex boundary canary; each run writes `case.json`, sanitized streams,
`result.json`, and `summary.json` under its selected evidence directory.

| Coverage | Protocol | Authoritative evidence |
| --- | --- | --- |
| Automated (opt-in) | One Codex native-onboarding plus `UserPromptSubmit` pre-turn boundary canary | `tests/live/verify_runtime.py`, `summary.json`, and case-local sanitized streams |
| Automated | Hook and tool structural contracts | `bash tests/run.sh` |
| Partial | Claude lifecycle hooks | deterministic hook tests; broader Claude delivery remains manual |
| Manual | `/compact` survival, public marketplace propagation, skill-reasoning protocols | retained procedures below |

Never call a protocol passed without a retained runtime-versioned `summary.json`.
The maintained workflow starts only that one positive Codex session, with Luna,
low reasoning, a disposable user layer containing only authentication and the
test collector whose output path is passed explicitly, ignored rules, web search disabled, ephemeral JSONL output, and
read-only sandboxing. It never retries; it uploads sanitized
evidence for every terminal verdict. Deterministic tests remain authoritative for
absence, subagent, drift, silence, and host-launcher lifecycle behavior. Use the
manual protocols below when broader Codex or Claude runtime behavior is needed.

### Agent-outcome benchmark (opt-in)

Run deterministic checks with `bash tests/run.sh`. Run the small live pilot with
`python3 benchmarks/agent-outcomes/pilot.py --output benchmarks/agent-outcomes/pilots/<label> --timeout 60`; it is cost-bearing and never reportable. Inspect or regrade a retained trial with `python3 benchmarks/agent-outcomes/tasks/command-discovery/grader.py <trial>/final-tree`. Published benchmark evidence identifies its runtime, model-version limitation, source/experiment revision, and artifact inventory; it makes no universal model-quality claim.

### Lean Codex canary profile

The frozen canary is one `command-discovery` trial under `aiboarding-full`, with
no retries. It uses `gpt-5.6-luna`, low reasoning effort, ignored user
configuration, ephemeral JSONL output, and a `workspace-write` sandbox; web
search remains disabled. It proves the Codex/onboarding/evidence/grading plumbing
only, not comparative model behavior. Validate its declared plan and trial ceiling
before any paid run:

```bash
python3 benchmarks/agent-outcomes/benchmark.py benchmarks/agent-outcomes/experiments/codex-maintained-outcomes-v8-canary.json --fingerprint
python3 benchmarks/agent-outcomes/pilot.py --profile benchmarks/agent-outcomes/experiments/codex-maintained-outcomes-v8-canary.json --dry-run --output /tmp/codex-maintained-dry-run
```

Only an authenticated maintainer should run the explicit cost-bearing command.
It has a 60-second bound and retains failures, timeouts, and incomplete trials
without tuning or rerunning cells. Optional `codex debug prompt-input` inspection
may help troubleshoot model-visible onboarding, but is not required evidence:

```bash
codex debug prompt-input --help
python3 benchmarks/agent-outcomes/pilot.py --profile benchmarks/agent-outcomes/experiments/codex-maintained-outcomes-v8-canary.json --output benchmarks/agent-outcomes/results/codex-maintained-outcomes-v8-canary
```

Never place credentials, home-directory configuration, or unrelated environment
data in that result directory. Regenerate and inspect the unpublished diagnostic
gate without invoking Codex, then regrade retained snapshots:

```bash
python3 benchmarks/agent-outcomes/pilot.py --profile benchmarks/agent-outcomes/experiments/codex-maintained-outcomes-v8-canary.json --offline benchmarks/agent-outcomes/results/codex-maintained-outcomes-v8-canary --output benchmarks/agent-outcomes/results/codex-maintained-outcomes-v8-canary
python3 benchmarks/agent-outcomes/tasks/command-discovery/grader.py benchmarks/agent-outcomes/results/codex-maintained-outcomes-v8-canary/command-discovery/aiboarding-full/<session>/final-tree
```

Incomplete evidence blocks comparison expansion. A complete objective pass or
complete objective fail is a viable canary outcome; neither is comparative
evidence, and no comparison is needed when no comparative claim is needed.
Historical `v7` diagnostics remain unchanged and unpublished.

Only after `diagnostic-gate.json` reports `"viable": true` may an authorized
maintainer explicitly spend on the larger comparison. This is a separate command;
the diagnostic never starts it automatically:

```bash
python3 benchmarks/agent-outcomes/pilot.py --profile benchmarks/agent-outcomes/experiments/codex-maintained-outcomes-v6.json --expand-from benchmarks/agent-outcomes/results/codex-maintained-outcomes-v8-canary/diagnostic-gate.json --output benchmarks/agent-outcomes/results/codex-maintained-outcomes-v6
```

If the diagnostic is incomplete, do not rerun cells automatically or run the
comparison. Keep its retained files for diagnosis. The existing offline packaging
and reporting rules remain authoritative for any later comparison.

Latest local live attempt (2026-08-23): Claude Code 2.1.237 failed both
native-load controls because its OAuth session could not refresh; Codex CLI
0.149.0 timed out both controls at the local 15-second bound. Both outcomes are
recorded as failures in retained local evidence, not passes. Lifecycle live
protocols therefore remain manual/partial until a protected runtime can produce
attributable event evidence.

Codex CLI 0.149.0 subsequently passed both native-load controls on 2026-08-23
with `codex exec --json --ephemeral --sandbox read-only` and a 25-second bound:
the positive stream contained its generated canary and the negative stream
returned `NONE`, with no tool-event path accepted by the harness.

The no-model local marketplace controls did pass on 2026-08-23 in disposable
runtime homes for both CLIs: valid local AIBoarding installs succeeded and an
unknown package was rejected. Public marketplace propagation remains manual.

# aiboarding - Verification Runbook

These protocols verify the behaviors that the bash test suite structurally cannot
reach: the marketplace install path (2a) and the live-runtime loading/hook behaviors
(3a). Each protocol is **manual** - run it against a live Claude Code install. Record
the outcome in `CHANGELOG.md` / `RELEASE-NOTES.md` when an item is confirmed.

## Release CI evidence

Before tagging a release, fetch `origin/main`, set `target_sha=$(git rev-parse origin/main)`, and run `bash tools/verify-release-sha "$target_sha"`. It requires GitHub-recorded successful push runs for that exact SHA; local harness output and maintainer claims do not substitute for this gate. Release changes enter `main` through a pull request with required checks.

**What the bash suite already covers** (no manual protocol needed): every hook
script's emitted JSON and silence conditions (`tests/hooks/`), the deterministic
tools' guarantees (`tests/tools/`), and the drift-classification matrix - including
the regression tests for issue #1's class (state-only and onboarding-only commit
ranges must not nudge; see `tests/hooks/test-drift-check.sh`).

### Onboarding mutation corpus

Run `bash templates/tools/verify-onboarding-mutations tests/fixtures/mutations validate`, then `bash templates/tools/verify-onboarding-mutations tests/fixtures/mutations computed`. Semantic review records `corpus`, audit skill revision, runtime/model, review date, outcome, category, and locations in a separate evidence TSV. Aggregate with `bash templates/tools/verify-onboarding-mutations tests/fixtures/mutations report <evidence.tsv>`: `0` all killed, `1` survivors, `2` incomplete. Challenge score excludes syntax-baseline preservation kills and measures maintained-corpus coverage only.

**Retired protocols:**
- **1a (`PreToolUse[Task]` injection canary)** - retired in v0.4.0. The `pre-task`
  hook and its design-only `updatedInput` Mechanism B are deleted; sub-agent context
  now uses the native `SubagentStart` event (covered by 3a.3 below).
- **1e (`update-aiboarding` reasoning branches)** - superseded. The deterministic
  halves (no-op silence, in-sync silence, empty-pointer nudge) are automated in
  `test-drift-check.sh`; the reasoning halves are re-expressed against the new skills
  in 4a below.

---

## 2a - Marketplace install (manual)

**Setup:** the repo pushed to `gustavo-meilus/aiboarding` with
`.claude-plugin/marketplace.json` on `main`.

**Steps:**
1. `/plugin marketplace add gustavo-meilus/aiboarding`
2. `/plugin install aiboarding@aiboarding`
3. Locally: `claude plugin validate . --strict` must pass before any release.

**Expected:** marketplace adds without error; plugin installs; the five skills
(`create-agent-onboarding`, `update-agent-onboarding`, `migrate-aiboarding`,
`compress-onboarding`, `audit-agent-onboarding`) appear in the skill list
(plugin-namespaced as `/aiboarding:<name>`); the hook and tool templates are
present in the installed plugin. Existing callers must migrate
`create-aiboarding` to `create-agent-onboarding` and `update-aiboarding` to
`update-agent-onboarding`.

**Pass:** all commands succeed and all skills are listed.
**Fail:** any resolution error → re-check `name`/`source` in `marketplace.json`.

---

## 3a - Live loading & hook-event matrix (manual, canary-based)

**Setup:** a scratch repo where `create-agent-onboarding` has run: `AGENTS.md`
(plant a unique canary string in its body, e.g. `CANARY-AGENTS-7F3A`), `CLAUDE.md`
with `@AGENTS.md`, `.aiboarding/` hooks + state, merged `.claude/settings.json`.
Start sessions with `claude --debug` so hook firing is visible.

### 3a.1 - Native import expansion
Ask a fresh session: "What onboarding context do you have? Quote any canary token."
**Pass:** the reply contains `CANARY-AGENTS-7F3A` (the `@AGENTS.md` import expanded).
**Fail:** canary absent → the whole native-delivery bet is broken for this Claude
Code version; check the import syntax and file locations before anything else.

### 3a.2 - /compact survival
Fill context, run `/compact`, re-ask for the canary.
**Pass:** canary still visible (project-root `CLAUDE.md` re-injected from disk).

### 3a.3 - SubagentStart reminder
Spawn a sub-agent whose prompt asks it to report any onboarding pointer it received.
**Pass:** the sub-agent's reply reflects the `<aiboarding-pointer>` reminder (it
names `AGENTS.md` and the binding sections). The debug output shows the
`subagent-start` hook firing.
**Fail (hook fired, no pointer visible):** document as a known limitation - do NOT
resurrect full-document injection; the fallback is instructing sub-agent prompts
manually.

### 3a.4 - `if`-filter narrowing
With debug output visible, run a non-git Bash command, then a git command.
**Pass:** the `drift-check` process spawns only for the git command.
**Degraded-OK:** if this Claude Code version ignores `if`, the hook must still stay
behaviorally silent on the non-git command (stdin self-gate) - spawn cost only.

### 3a.5 - InstructionsLoaded diagnostics
Set `AIBOARDING_DEBUG=1`, start a session, inspect `.aiboarding/logs/hooks.log`.
**Pass:** the log lists `CLAUDE.md` with `load_reason: session_start` (and any
`.claude/rules/*.md` with their reasons).
**Degraded-OK:** if the event never fires on this version, remove the
`InstructionsLoaded` settings entry; everything else is unaffected.

---

## 3b - Codex plugin hooks (manual, unrun protocol)

Record Codex version, plugin revision, trust state, each command, and pass/fail
evidence. Do not claim this protocol passed until run in a live Codex install.

1. Record the Codex version, host, and hook trust state. Install or enable the AIBoarding plugin, open `/hooks`, inspect the bundled
   `hooks/hooks.json`, and trust its current definition. Confirm changed hooks return
   to review rather than running automatically.
2. In a Git scratch repo, add a unique canary to `AGENTS.md`, start Codex, and ask
   for the canary. Pass: native `AGENTS.md` loading exposes it; valid `SessionStart`
   adds no lifecycle message.
3. Start a subagent. Pass: it receives only the `AGENTS.md` pointer naming binding
   sections, never the canary/body.
4. Run non-Git Bash activity. Pass: no drift signal. Commit an `AGENTS.md`-only
   change, then a code change, and run Git after each. Pass: irrelevant range stays
   silent; relevant range signals `update-agent-onboarding`.
5. Disable the hook in `/hooks` (or run untrusted). Pass: skills still work and the
   documented fallback is manual `update-agent-onboarding` after meaningful commits.

Repeat the applicable host check and retain its output with the record:

- **Native Windows with Git Bash:** run the exact `commandWindows` command from
  `hooks/hooks.json` through `cmd.exe` in a Git scratch repository whose path contains
  spaces. A JSON-escaped Windows `cwd` must produce drift context after a relevant Git
  change; a non-Git Bash command stays silent.
- **Native Windows without compatible Git Bash:** invoke the same command after
  removing Git for Windows from executable discovery. It exits successfully and emits
  no context; record manual `update-agent-onboarding` as the lifecycle fallback.
- **WSL, Linux, or macOS:** run the Unix `command` value through Bash. It must deliver
  the same relevant/irrelevant lifecycle decisions as the adapter fixture.

Official reference: <https://learn.chatgpt.com/docs/hooks>.

---

## 4a - Skill reasoning branches (manual)

Drift categories: `irrelevant` means only exact onboarding/state bookkeeping or
configured ignored paths; `semantic-review` requires section-by-section evidence;
`mandatory-revalidation` records high-risk signals and revalidates applicable
sections; `invalid-pointer` revalidates all sections. `high_risk_paths` overrides
`ignored_paths`. After upgrading an existing Claude installation, run
`update-agent-onboarding` once to refresh managed `drift-check` and `classify-drift`;
missing managed assets must revalidate, never silently advance. Rollback can restore
old hook/tool copies: optional receipt and configuration fields remain readable by old
readers.

Each case runs in a scratch repo where `create-agent-onboarding` has already run, so
`AGENTS.md` + `CLAUDE.md` + `.aiboarding/state.json` exist with
`last_synced_commit` = current `HEAD`.

### Case 1 - No-op branch
**Steps:** make a scope-irrelevant commit (typo in a code comment); run
`/update-agent-onboarding`.
**Pass:** `state.json` pointer advances to the new `HEAD`;
`git diff AGENTS.md CLAUDE.md` is **empty** (the hard invariant); no approval
prompt; brief report.

### Case 2 - Targeted-delta branch
**Steps:** make a scope-relevant commit (add a runtime dependency or a new domain
concept); run `/update-agent-onboarding`.
**Pass:** the scoped grill fires for *only* the affected sections; untouched
sections are byte-for-byte identical; compression runs on the re-drafted text with
`check-preservation` clean; an approval gate precedes the write; the pointer
advances *after* approval.

### Case 3 - Hook-loop sanity
**Steps:** after Case 1 or 2, commit the state/doc changes, then run any git command.
**Pass:** the `drift-check` hook stays silent (onboarding-only range → no nudge).

### Case 4 - Repair guard
**Steps:** blank out `last_synced_commit` in `state.json`, then run triage.
**Pass:** triage routes to a full re-validation of all nine sections (never the
silent no-op branch), then reseeds the pointer.

### Case 5 - Migration
**Steps:** in a repo with only a legacy `AIBOARDING.md`, run `/migrate-aiboarding`.
**Pass:** a single preview lists every write before anything happens; after
approval: `AGENTS.md` carries the mapped v1 content, `state.json` carries the old
pointer, `pre-task`/`post-commit` entries and files are gone, and the legacy doc is
archived (or banner-fenced) per the user's choice.

---

## 5a - Self-host lifecycle acceptance (manual)

Run in a disposable clone of AIBoarding. Keep the maintained checkout unchanged.
Use only `create-agent-onboarding`, `update-agent-onboarding`,
`audit-agent-onboarding`, and `compress-onboarding`; `tests/self-host/test-managed-repo.sh`
covers deterministic layout invariants.

1. Run `create-agent-onboarding`, approve unchanged canonical guidance, then run it
   again. Record hashes for `AGENTS.md`, `CLAUDE.md`, state field count, managed
   hook count, and settings entries. Pass: one managed copy and entry per event;
   user-owned content unchanged.
2. Commit a scope-irrelevant change. Hash `AGENTS.md` and `CLAUDE.md`, run
   `update-agent-onboarding`, then compare hashes. Pass: both hashes identical and
   only `.aiboarding/state.json` advances.
3. Commit an onboarding-relevant change, such as a new command or domain concept.
   Run `update-agent-onboarding`. Pass: it identifies affected canonical scope,
   requests approval before guidance write, and preserves untouched sections.
4. Commit only managed onboarding files and `.aiboarding/` bookkeeping. Run a git
   command. Pass: drift hook emits no nudge.
5. Run `audit-agent-onboarding`, `compress-onboarding` preservation checks, and
   `.aiboarding/tools/check-size-budget AGENTS.md`. Pass: no unresolved `FAIL`,
   protected spans survive, local guidance is within its sensor budget, and audit
   confirms effective Codex chains fit their configured runtime limit.
6. Record command output and hashes with result. Remove disposable clone after
   evidence is captured. Do not replace fixture protocols or commit probe changes
   into maintained checkout.

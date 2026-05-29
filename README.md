# aiboarding: Onboard AI Agents Like Fresh Engineers

aiboarding treats every AI coding agent as a new hire. It maintains one compressed, high-signal `AIBOARDING.md` per repository — the project's engineering basics, domain logic, and AI-specific gotchas — and guarantees, via committed hooks, that agents read it on entry and keep it current as the code evolves. No more re-explaining the codebase to every fresh session, sub-agent, or post-compaction context.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Status: early](https://img.shields.io/badge/status-v0.1.3%20early-orange.svg)](./RELEASE-NOTES.md)

> **Status — v0.1.3.** The full **create → sync → update** lifecycle is implemented: the plugin scaffold, the cross-platform `sync` hook templates (with a full test harness), the **`create-aiboarding` skill** (hybrid crawl + grilling generator that writes `AIBOARDING.md` and installs the hooks), and the **`update-aiboarding` skill** — the commit-triggered drift-triage that auto-advances the sync pointer on no-op changes and runs a targeted-delta patch when scope drifts. v0.1.3 adds the **marketplace listing** (`/plugin install aiboarding@aiboarding` now resolves) and a committed **[verification runbook](./docs/VERIFICATION.md)** for the runtime behaviors the test harness can't reach. Those live-runtime checks (hook injection, skill reasoning) are documented but not yet run against the live Claude Code runtime (see [Roadmap](#roadmap)).

---

## The Idea

A new engineer joining a project gets onboarded: they read the docs, learn the stack, absorb the domain language, and get warned about the landmines. AI agents get none of that — they re-derive context from scratch every session, and they repeat the same mistakes. aiboarding closes that gap with a three-stage lifecycle:

| Stage | Component | What it does |
| :--- | :--- | :--- |
| **Create** | `create-aiboarding` | Generates `AIBOARDING.md` via a hybrid background code-crawl + relentless grilling interrogation, caveman-compresses it, then installs the hooks. |
| **Sync** | `sync-aiboarding` | Injects the document into every agent's context — at session start, after compaction, and into spawned sub-agents. |
| **Update** | `update-aiboarding` | On every commit, triages the diff against the doc's scope and patches only the sections that drifted (auto-advances the pointer on no-op changes). |

---

## How Sync Works

Skills cannot guarantee their own invocation — only **hooks** can. aiboarding's enforcement layer is therefore a set of committed, deterministic hook scripts, not model-invoked skills.

| Event | Hook | Behavior |
| :--- | :--- | :--- |
| `SessionStart` (`startup\|clear\|compact`) | `session-start` | Emits `AIBOARDING.md` as session context. Missing doc → prompts `create-aiboarding`. |
| `PreToolUse` (`Task`) | `pre-task` | Prepends the doc to spawned sub-agents (no native sub-agent-spawn hook exists). |
| `PostToolUse` (`Bash`) | `post-commit` | Compares frontmatter `last_synced_commit` to git `HEAD`; nudges `update-aiboarding` on drift. |

All three run through a single **polyglot `run-hook.cmd`** — one file valid as both Windows CMD and bash. On Windows it locates Git Bash and dispatches; on macOS/Linux bash treats the CMD block as a no-op heredoc and runs the script directly. If no bash is found on Windows, injection degrades silently rather than erroring. The pattern is adapted from [obra/superpowers](https://github.com/obra/superpowers).

---

## The `AIBOARDING.md` Document

Drift state lives in YAML frontmatter; the body is three caveman-compressed sections.

```markdown
---
aiboarding_version: 1
generated: 2026-05-29
last_synced_commit: <sha>
---
# 1. Engineering Basics     — stack, build, test, run commands
# 2. Domain & Business Logic — what it does, why, core concepts
# 3. AI-Specific Context     — gotchas, known failure modes, guardrails
```

`last_synced_commit` is the single drift signal: `update-aiboarding` diffs `<last_synced_commit>..HEAD` to decide whether the document needs a patch.

---

## Quick Start

```text
# Claude Code
/plugin marketplace add gustavo-meilus/aiboarding
/plugin install aiboarding@aiboarding
```

Then generate the doc and wire up enforcement in one pass:

```text
/create-aiboarding      # interview + crawl → writes AIBOARDING.md, installs the hooks
# ...from then on, every session, sub-agent, and post-compaction context is auto-onboarded
/update-aiboarding      # triage drift after commits → targeted-delta patch (or silent pointer advance)
```

> As the code evolves, the `post-commit` hook nudges you when `AIBOARDING.md` may have drifted;
> running `/update-aiboarding` triages the diff and patches only the affected sections — or
> silently advances the sync pointer when nothing in scope changed.

Run the test suite for the shipped hook templates (requires Git Bash on Windows):

```bash
bash tests/run.sh
```

---

## Repository Layout

```
aiboarding/
├── .claude-plugin/
│   └── plugin.json              # Claude Code plugin manifest
├── skills/
│   ├── create-aiboarding/
│   │   └── SKILL.md             # 5-phase generation + Phase 6 hook install
│   └── update-aiboarding/
│       └── SKILL.md             # commit-drift triage + targeted-delta patch
├── templates/
│   ├── hooks/                   # cross-platform hook scripts (installed into target repos)
│   │   ├── _lib                 # shared bash: json-escape, path resolve, frontmatter, emit
│   │   ├── session-start        # SessionStart injection + missing-doc fallback
│   │   ├── pre-task             # PreToolUse[Task] sub-agent injection
│   │   ├── post-commit          # PostToolUse drift nudge
│   │   └── run-hook.cmd         # polyglot CMD+bash dispatcher
│   └── settings/
│       └── hooks.json           # .claude/settings.json snippet
├── tests/                       # dependency-free bash harness (5 suites)
│   ├── run.sh · lib/assert.sh
│   ├── fixtures/                # with-doc / no-doc fixtures
│   └── hooks/                   # one test per hook + the shared lib
├── docs/superpowers/
│   ├── specs/                   # architecture umbrella + create/sync/update specs
│   └── plans/                   # implementation plans (Plans 1, 2 & 3 done)
├── .gitattributes               # pins LF for hook scripts
├── CHANGELOG.md · RELEASE-NOTES.md · LICENSE
```

---

## Contributing

Contributions are managed via issues and PRs at [gustavo-meilus/aiboarding](https://github.com/gustavo-meilus/aiboarding).

## License

MIT. See [LICENSE](./LICENSE).

---

## Star History

[![GitHub Stars](https://img.shields.io/github/stars/gustavo-meilus/aiboarding?style=social)](https://github.com/gustavo-meilus/aiboarding/stargazers)

[![Star History Chart](https://api.star-history.com/svg?repos=gustavo-meilus/aiboarding&type=Date)](https://star-history.com/#gustavo-meilus/aiboarding&Date)

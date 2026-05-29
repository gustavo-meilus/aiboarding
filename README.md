# aiboarding: Onboard AI Agents Like Fresh Engineers

aiboarding treats every AI coding agent as a new hire. It maintains one compressed, high-signal `AIBOARDING.md` per repository — the project's engineering basics, domain logic, and AI-specific gotchas — and guarantees, via committed hooks, that agents read it on entry and keep it current as the code evolves. No more re-explaining the codebase to every fresh session, sub-agent, or post-compaction context.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Status: foundation](https://img.shields.io/badge/status-v0.1.0%20foundation-orange.svg)](./RELEASE-NOTES.md)

> **Status — v0.1.0 (foundation).** This release ships the plugin scaffold and the cross-platform hook templates plus a full test harness. The user-facing skills that *generate* and *update* the document (`create-aiboarding`, `update-aiboarding`) and the installer that wires the hooks into a target repo are **designed and planned** (see [`docs/superpowers/`](./docs/superpowers/)) but **not yet implemented**. They are targeted for v0.2.0.

---

## The Idea

A new engineer joining a project gets onboarded: they read the docs, learn the stack, absorb the domain language, and get warned about the landmines. AI agents get none of that — they re-derive context from scratch every session, and they repeat the same mistakes. aiboarding closes that gap with a three-stage lifecycle:

| Stage | Component | What it does |
| :--- | :--- | :--- |
| **Create** | `create-aiboarding` *(planned)* | Generates `AIBOARDING.md` via a hybrid background code-crawl + relentless grilling interrogation, then caveman-compresses it for token efficiency. |
| **Sync** | `sync-aiboarding` *(hooks — shipped)* | Injects the document into every agent's context — at session start, after compaction, and into spawned sub-agents. |
| **Update** | `update-aiboarding` *(planned)* | On every commit, triages the diff against the doc's scope and patches only the sections that drifted. |

---

## How Sync Works (shipped in v0.1.0)

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

> The generation/update skills land in v0.2.0. Today you can install the plugin and inspect the hook templates and design docs.

```text
# Claude Code (planned distribution)
/plugin marketplace add gustavo-meilus/aiboarding
/plugin install aiboarding@aiboarding
```

Once the v0.2.0 skills ship, the intended flow is:

```text
/create-aiboarding      # interview + crawl → writes AIBOARDING.md, installs the hooks
# ...from then on, every agent is auto-onboarded; commits trigger drift triage
```

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
│   └── plans/                   # implementation plans (Plan 1 done; 2 & 3 planned)
├── .gitattributes               # pins LF for hook scripts
├── CHANGELOG.md · RELEASE-NOTES.md · LICENSE
```

---

## Roadmap

- **v0.2.0** — `create-aiboarding` skill (5-phase generation + caveman compression) and the Phase 6 installer that copies the hook templates into a target repo and merges the settings snippet idempotently.
- **v0.3.0** — `update-aiboarding` skill (drift triage + targeted-delta patch).
- **Hardening** — live verification that `PreToolUse` `additionalContext` reaches sub-agents (else switch to `updatedInput`); narrow the `PostToolUse` matcher to `git commit` commands.

---

## Contributing

Contributions are managed via issues and PRs at [gustavo-meilus/aiboarding](https://github.com/gustavo-meilus/aiboarding).

## License

MIT. See [LICENSE](./LICENSE).

---

## Star History

[![GitHub Stars](https://img.shields.io/github/stars/gustavo-meilus/aiboarding?style=social)](https://github.com/gustavo-meilus/aiboarding/stargazers)

[![Star History Chart](https://api.star-history.com/svg?repos=gustavo-meilus/aiboarding&type=Date)](https://star-history.com/#gustavo-meilus/aiboarding&Date)

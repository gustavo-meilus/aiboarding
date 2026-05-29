# Design Spec: `aiboarding` — System Architecture

## Overview
`aiboarding` treats every AI agent as a fresh software engineer. It maintains one
compressed, always-current `AIBOARDING.md` per repository and guarantees — via
committed hooks — that agents read it on entry and keep it fresh as the project
evolves. The system spans a three-stage lifecycle: **create → sync → update**.

This is the umbrella spec. It defines the shared contracts (document schema, hook
layout, drift-tracking, installation) that the three component specs depend on.
Each component is specced and built separately:

* `create-aiboarding` — already specced (`2026-05-28-create-onboarding-design.md`).
* `sync-aiboarding` — to be specced.
* `update-aiboarding` — to be specced.

## Components & Relationships

```
create-aiboarding   (skill)        generate AIBOARDING.md from scratch  [5-phase flow]
        │ produces
        ▼
   AIBOARDING.md  ◄──── sync-aiboarding   (hooks)   inject doc into every agent context
        │                  • SessionStart (startup|resume|compact)  → inject doc
        │                  • PreToolUse[Task]                       → prepend doc to sub-agent
        │                  • doc missing → emit "run create-aiboarding"
        │ tracked against
        ▼
update-aiboarding  (hook + skill)  detect drift, re-run an update pass
                   • PostToolUse[git commit] → triage diff + chat log
                   • scope changed? → invoke update flow (create-like)
```

* **`create-aiboarding`** is a reasoning skill. Its final phase also installs the
  `sync` and `update` hooks into the repo (see Installation).
* **`sync-aiboarding`** is a hook bundle, **not** a reasoning skill. A `SessionStart`
  hook that emits the document as `additionalContext` *is* the sync — no model
  reasoning is required. Its only non-deterministic moment is the missing-document
  fallback, which simply emits a prompt to run `create-aiboarding`.
* **`update-aiboarding`** is a hook (deterministic trigger) plus a skill (the
  triage + update reasoning).

## `AIBOARDING.md` Schema
The document carries drift-tracking metadata in YAML frontmatter. The body is three
sections, caveman-compressed for token efficiency.

```markdown
---
aiboarding_version: 1
generated: 2026-05-29
last_synced_commit: <sha>
---
# 1. Engineering Basics
Stack, build, test, and run commands. Standard engineering basics extracted
automatically from dependency files and project structure.

# 2. Domain & Business Logic
What the project does, why it exists, and its core domain concepts — extracted
from the user via the grilling interrogation.

# 3. AI-Specific Context
Gotchas, known AI failure modes, and guardrails that prevent future sub-agents
from repeating mistakes.
```

* `aiboarding_version` — schema version, for future retro-compatibility checks.
* `generated` — date the document was first created.
* `last_synced_commit` — the commit SHA the document was last reconciled against;
  the baseline for drift detection.

## Hook Layout
Hooks live in `.claude/settings.json`, **committed per-project** so they travel with
the team. They are thin scripts that emit context — they do **not** perform LLM work.

| Event | Matcher | Script behavior |
|---|---|---|
| `SessionStart` | `startup\|resume\|compact` | Read `AIBOARDING.md`; emit its body as `additionalContext`. If absent, emit a prompt to run `create-aiboarding`. |
| `PreToolUse` | `Task` | Prepend `AIBOARDING.md` to the spawned sub-agent's prompt. |
| `PostToolUse` | `Bash` containing `git commit` | Run the `update-aiboarding` triage. |

A single `SessionStart` hook covers session start, resume, and **after compaction**
by branching on the `source` field — these collapse into one injection point. There
is no native sub-agent-spawn hook in Claude Code, so sub-agent injection is handled
via `PreToolUse` on the `Task`/`Agent` tool.

## Installation / Bootstrap
Because hooks are per-project committed, something must write `.claude/settings.json`
and the hook scripts into the repo. The final phase of **`create-aiboarding`** performs
this install: it is already writing to the repo root, so it bootstraps the entire
system — document plus hooks — in one pass. No separate init skill is introduced (YAGNI).

## Drift Detection
`last_synced_commit` in the frontmatter is the baseline. The `update-aiboarding` triage,
fired by the `PostToolUse[git commit]` hook:

1. Runs `git diff <last_synced_commit>..HEAD` plus a scan of the recent chat log.
2. Decides whether the change touches the document's scope.
3. Escalates to a full update pass **only** if scope changed; otherwise no-ops and
   advances `last_synced_commit`.

## Build Order
1. **This umbrella spec.**
2. Revise the existing `create-aiboarding` spec to reference this umbrella and add the
   hook-installation phase.
3. Spec and build `sync-aiboarding` (hook bundle).
4. Spec and build `update-aiboarding` (hook + skill).

# AIBoarding and Loop Engineering

## What Loop Engineering is

Loop Engineering is the practice of designing the repeatable control system around an AI agent instead of prompting it step by step. A well-built loop has a narrow goal, a trigger, context loading, tool permissions, a real verifier, a stop condition, durable memory, and a safety boundary.

The term gained traction in June 2026 after Addy Osmani's post ([addyosmani.com/blog/loop-engineering](https://addyosmani.com/blog/loop-engineering/)), which frames the shift as "designing loops that prompt your agents" and names five primitives: automations, worktrees, skills, plugins/connectors, and subagents. LangChain describes the same idea as stacked loops: the basic agent loop, a verification loop, an event-driven loop, and a trace-driven improvement loop ([langchain.com/blog/the-art-of-loop-engineering](https://www.langchain.com/blog/the-art-of-loop-engineering)).

One thing every serious treatment of the topic agrees on: a loop is only as good as the context it starts from and the verification it ends with. Without those, a loop just automates mistakes faster.

## Where AIBoarding sits

AIBoarding is **not** a loop runner. It does not schedule agents, dispatch subagents, or gate merges. It owns one specific layer of the loop, the one every other layer depends on:

> **Durable repo context: generated, compressed, audited, and kept current.**

| Loop ingredient | AIBoarding role |
| :--- | :--- |
| Goal / context | Captures repo purpose, stack, architecture, commands, guardrails in `AGENTS.md` |
| Tool use | Gives agents exact build, test, and run commands so they don't guess |
| Observation | Tracks commits since the last sync in `.aiboarding/state.json` |
| Verification | Records the required checks in a Verification Before Completion section |
| Retry / escalate | Documents known failure modes and explicit ask-the-user conditions |
| Memory / trace | Stores drift state and compression receipts outside the transient chat context |
| Safety | Audits for secrets, stale commands, contradictions, and context bloat |

Every loop iteration begins with context loading. If that context is stale, bloated, or contradictory, the loop inherits the defect on every run. AIBoarding's job is to make the context layer trustworthy:

- **Fresh**: the drift hook nudges after relevant commits; `update-agent-onboarding` patches only the affected sections.
- **Compact**: `compress-onboarding` reduces token cost while byte-preserving commands, paths, URLs, and code, with machine-verified receipts.
- **Audited**: `audit-agent-onboarding` catches bloat, stale commands, contradictions, secret-like tokens, and the Codex 32 KiB truncation cap before an agent trips over them.

## Honest boundaries

Claims we make and claims we don't:

- AIBoarding maintains standard agent onboarding files (`AGENTS.md`, a thin `CLAUDE.md` wrapper, a state sidecar). It does not make agents "understand any codebase perfectly"; it gives them a maintained starting context and a verification checklist.
- AIBoarding does not replace prompting, skills, or evals. It makes the durable-context part of those systems maintainable.
- Drift *nudging* is a Claude Code hook. On other runtimes you run the update skill manually after meaningful commits.

## Companion tooling

For the loop-runner side of the picture (spec generation, agent coordination, isolated review, bounded repair, resumable state), AIBoarding pairs well with [superpipelines](https://github.com/gustavo-meilus/superpipelines), which positions itself as Loop Engineering with structural review boundaries. The division of labor is simple: **AIBoarding gives agents memory; a pipeline framework gives them discipline.** Each works without the other.

## References

- Addy Osmani, "Loop Engineering" (June 7, 2026): https://addyosmani.com/blog/loop-engineering/
- LangChain, "The Art of Loop Engineering": https://www.langchain.com/blog/the-art-of-loop-engineering
- AGENTS.md, the open cross-agent instruction format: https://agents.md/

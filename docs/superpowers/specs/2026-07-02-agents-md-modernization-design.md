# AGENTS.md modernization - design (v0.3.0–v0.5.0)

AIBoarding pivots from a *custom Markdown injector* to a *lifecycle manager for
standard agent onboarding files*. The platform moved underneath the v1 design:
Claude Code natively loads `CLAUDE.md` (with `@AGENTS.md` imports and `/compact`
survival), ships `SubagentStart` and `InstructionsLoaded` hook events, and
supports `if` permission-rule filters on hooks - while `AGENTS.md` became the
cross-agent onboarding standard read natively by Codex, Copilot, Cursor, and
others. Full-document `SessionStart` injection, the `PreToolUse[Task]` sub-agent
workaround, and the broad self-gated `PostToolUse[Bash]` matcher are all
obsolete.

## Target layout (generated into target repos)

```
repo-root/
├── AGENTS.md                 # canonical cross-agent onboarding (9 H2 sections)
├── CLAUDE.md                 # thin wrapper: @AGENTS.md + fenced Claude-only notes
├── .aiboarding/
│   ├── state.json            # sync pointer + compression receipts (committed)
│   ├── config.json           # compression level, size budgets, ignored_paths
│   ├── .gitignore            # logs/
│   ├── hooks/                # run-hook.cmd, _lib, session-start,
│   │                         # subagent-start, drift-check, instructions-loaded
│   ├── tools/                # inject-fenced, check-size-budget, check-preservation
│   └── logs/                 # debug-only, untracked
└── .claude/settings.json     # 4-event hook wiring (merged, idempotent)
```

## Structural fix for issue #1

The v1 pointer lived inside the committed instruction file, so advancing it
always re-fired the drift hook (v0.2.0 patched the symptom with doc-only-range
suppression). v2 moves the pointer to `.aiboarding/state.json`: **advancing the
sync pointer never modifies a visible instruction file.** The drift hook's range
classification becomes config-driven - an always-ignored set (`AGENTS.md`,
`CLAUDE.md`, `.aiboarding/*`) plus `config.json:ignored_paths` globs - replacing
the hardcoded v0.2.0 rule. The legacy branch of `drift-check` retains the exact
v0.2.0 logic for unmigrated repos.

## Hook strategy: delivery is native, hooks are surgical

| Event | Hook | v2 behavior |
| :--- | :--- | :--- |
| `SessionStart` | `session-start` | Fallback only: silent when `AGENTS.md` + `CLAUDE.md` (with `@AGENTS.md`) exist; warns naming what's missing; nudges migration on legacy layout. Never emits file bodies. |
| `SubagentStart` | `subagent-start` | Short pointer reminder (never the doc body) - replaces the retired `pre-task` full-doc injection. |
| `PostToolUse` + `if: Bash(git *)` | `drift-check` | State-sidecar pointer vs HEAD; stdin git-gate as defense in depth for runtimes without `if` filters. |
| `InstructionsLoaded` | `instructions-loaded` | `AIBOARDING_DEBUG=1` → append payload to `.aiboarding/logs/hooks.log`; otherwise inert. |

Hook `timeout` values are **seconds**. `once` is not used (ignored in settings
files). `hookSpecificOutput.additionalContext` remains the delivery mechanism.

## State-read contract (no jq)

Hooks read `state.json`/`config.json` with `_lib`'s `json_get` /
`json_get_array_items`: pure-bash line scanners, not JSON parsers. Skills own the
writes and must keep one top-level key per line, arrays one quoted item per line.
Nested values (the `receipts` array) are skill-only territory.

## Skills

- `create-agent-onboarding` (alias: `create-aiboarding`) - v1 six-phase engine
  preserved; synthesis retargeted to the 9-section `AGENTS.md` schema; blocking
  validation gate; runtime-aware (Codex/Copilot runs skip hook wiring).
- `update-agent-onboarding` (alias: `update-aiboarding`) - no-op branch writes
  the state pointer only; targeted-delta patch byte-preserves untouched sections.
- `migrate-aiboarding` - one-shot v1→v2: frontmatter→state, 3-section→9-section
  mapping, hook rewiring, archive-or-banner for the legacy doc, single approval
  gate.
- `compress-onboarding` - standalone compression engine: levels
  `off/lite/full/ultra`, byte-preservation invariants enforced by
  `check-preservation`, clarity exemptions for Guardrails/Escalation, receipts
  in `state.json`.
- `audit-agent-onboarding` - read-only linter: size budget, Codex 32 KiB cap,
  duplication, contradictions, stale/vague commands, skill/lint leakage,
  secrets; `--stats` renders compression receipts.

## Deterministic tools (`templates/tools/`)

Judgment stays in skills; the enforceable halves ship as dependency-free bash so
the test harness can pin them: `inject-fenced` (idempotent
`<!-- aiboarding-begin/end -->` blocks), `check-size-budget` (220-line/24 KiB
warn, 32 KiB strict fail - Codex `project_doc_max_bytes`), `check-preservation`
(compression must not alter fenced blocks, backtick spans, URLs, or path
tokens).

## Cross-CLI distribution

`AGENTS.md` is the cross-agent payload and needs no adapters. The skills
themselves are standard SKILL.md (frontmatter kept to `name` + `description`),
so they also run under Codex (`.agents/skills/`, `.codex/skills/`) and Copilot
CLI (`.github/skills/`, `.claude/skills/`, `.agents/skills/`); `.agents/skills/`
is the documented common install path. Hook wiring is Claude Code-only and the
skills say so.

## Project Purpose

`AIBoarding` generates, compresses, audits, and maintains `AGENTS.md` onboarding guidance for AI coding agents.

## Stack and Runtime

Portable `SKILL.md` workflows, Bash hook/tool templates, JSON settings, Markdown docs. Supports Claude Code, Codex, Copilot CLI, Cursor, and OpenCode.

## Build, Test, Run

Fast/full suite: `bash tests/run.sh`.

Validate plugin before release: `claude plugin validate . --strict`.

Use `openspec` workflows for planned changes.

## Architecture Map

`skills/` owns lifecycle reasoning. `templates/` owns installed hooks, tools, state defaults, and settings. `tests/` verifies deterministic behavior. `docs/VERIFICATION.md` holds manual runtime protocols.

Flow: skills synthesize guidance and install template copies; hooks detect drift; `update-agent-onboarding` patches affected guidance or advances only `.aiboarding/state.json`.

## Domain Model

Canonical guidance: `AGENTS.md`. Claude adapter: `CLAUDE.md` importing `@AGENTS.md`. Operational state: `.aiboarding/state.json`. Configuration: `.aiboarding/config.json`. Sync pointer remains outside instruction files to prevent drift loops.

## Agent Guardrails

Keep hooks deterministic, small, and silent by default. Keep reasoning in skills, not hooks or tests. Do not add self-host-only lifecycle code. Preserve fixtures and public lifecycle behavior. Installed `.aiboarding/hooks/` and `.aiboarding/tools/` must byte-match `templates/`.

## Known Failure Modes

Do not duplicate canonical guidance in `CLAUDE.md`. Do not modify instruction files during no-op drift updates. Do not ignore `README.md` for this repository: it is authoritative onboarding input. Do not replace manual reasoning protocols with inaccurate Bash simulations.

## Verification Before Completion

Run `bash tests/run.sh`. For self-host changes, run `bash tests/self-host/test-managed-repo.sh`, `.aiboarding/tools/check-size-budget AGENTS.md`, preservation checks, and audit workflow. Run `claude plugin validate . --strict` before release work.

## Escalation - Ask the User When

Ask before changing public lifecycle semantics, plugin packaging, compatibility, or generated guidance content requiring product judgment. Ask before destructive Git operations or when self-host setup would alter user-owned settings content.

## More With Less engineering policy

For non-trivial project work, load and follow `$more-with-less` before choosing the implementation approach. Build the minimum sufficient solution while preserving correctness, security, data integrity, accessibility, operability, acceptance criteria, and rollback safeguards. Understand relevant behavior before simplifying; prefer deletion/reuse, native mechanisms, installed dependencies, deterministic checks, one agent by default, and proportional specification/verification. Before completion, run the authoritative project check, report the evidence obtained, and inspect the diff for unrelated or unnecessary changes.

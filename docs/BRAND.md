# AIBoarding brand sheet

## Position

AIBoarding is a repository-onboarding lifecycle for maintainers using AI coding agents. It creates and keeps canonical `AGENTS.md` guidance current across supported agents, avoiding duplicated instruction sources and broad rewrites of unchanged guidance.

**Promise:** A current boarding pass for every coding agent.
**Failure mode:** onboarding drift.

## Voice and palette

Be factual, concise, and specific about evidence and limits. Do not promise response times, universal agent outcomes, or live-runtime support that has not been verified.

| Token | Value | Use |
| --- | --- | --- |
| Navy | `#101828` | base and dark surface |
| Teal | `#14b8a6` | route/action |
| Blue | `#2563eb` | verification |
| Light | `#f8fafc` | light surface |

## Evidence ledger

| Public claim | Source and qualification |
| --- | --- |
| v1.0.0 is the current release | `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `CHANGELOG.md`, `RELEASE-NOTES.md`, and the v1.0.0 GitHub release. |
| Core lifecycle is implemented | `bash tests/run.sh`; live runtime behavior remains opt-in and may be unavailable. |
| Benchmark observations exist | `benchmarks/agent-outcomes/results/codex-command-discovery-v2/report.md`; results are task- and runtime-bound, not general quality claims. |
| Portable skills work outside Claude | `skills/*/SKILL.md`; copied installs do not wire lifecycle hooks and require manual updates. |

## Assets

Master: `assets/aiboarding-icon.svg` (document, route, check). Derived: `aiboarding-icon-512.png`, light/dark wordmarks, lifecycle demo, and social preview. All SVGs are self-contained; PNGs are flattened derivatives.

## Review record

2026-08-25: reviewed every final asset in Edge at its intended size and at 32 px. The light and dark wordmarks, icon, demo, and social preview remained legible and recognizable. `bash tests/docs/test-branding.sh` proves structure and links; it cannot prove composition, contrast, or GitHub rendering and does not replace visual review.

## GitHub metadata — administrator action required

- [ ] Set description: `Keep AGENTS.md alive: canonical onboarding for AI coding agents.`
- [ ] Set topics: `ai-agents`, `agents-md`, `claude-code`, `codex`, `copilot`, `developer-tools`, `documentation`, `onboarding`.
- [ ] Upload `assets/aiboarding-social-preview.png` in repository Settings → General → Social preview.
- [ ] Verify the live description, topics, and preview after saving. Repository commits do not perform these actions.

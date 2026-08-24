## Context

See `proposal.md` for motivation and `specs/codex-lifecycle-hooks/spec.md` for required behavior. AIBoarding currently ships portable skills and Claude-oriented project hook templates. The Codex manifest already advertises `Hooks`, but contains no hook entry or default `hooks/hooks.json`, so that claim is not backed by shipped Codex lifecycle behavior.

Current [Codex hook documentation](https://learn.chatgpt.com/docs/hooks) and [plugin packaging guidance](https://developers.openai.com/plugins/build/plugins#bundled-mcp-servers-and-lifecycle-hooks) establish native plugin-bundled hooks, trust review, `PLUGIN_ROOT`, and the relevant `SessionStart`, `SubagentStart`, and `PostToolUse` events. Codex reads `AGENTS.md` natively; a hook must not inject its body. Codex `PostToolUse` can match `Bash`, but command-level Git filtering must inspect `tool_input.command`. Hook payloads and output envelopes differ at the adapter boundary, while drift classification and repository state do not.

The concurrent `harden-onboarding-drift-classification` change defines the intended shared classifier, routes, and fail-safe state semantics. This change must reuse that authority if it lands first, or establish the same runtime-neutral boundary without forking those semantics.

## Goals / Non-Goals

**Goals:**

- Make Codex lifecycle delivery a thin adapter over shared repository decisions.
- Keep plugin-bundled hooks quiet, deterministic, trust-aware, and cross-platform.
- Preserve native `AGENTS.md` delivery and minimal subagent context.
- Make manifest claims mechanically traceable to packaged files and tests.

**Non-Goals:**

- Unify Claude and Codex hook configuration syntax or output envelopes.
- Install repo-local Codex settings when plugin-bundled hooks suffice.
- Turn advisory nudges into automatic onboarding edits or retry loops.
- Add another drift classifier, service, dependency, or document-loading path.

## Decisions

### Bundle one Codex hook entrypoint and keep repository decisions runtime-neutral

Add a Codex-owned `hooks/hooks.json` under the plugin root and point the manifest at it explicitly. Its handlers call a small cross-platform entrypoint using `PLUGIN_ROOT`; `commandWindows` handles Windows without embedding platform detection into business logic. The entrypoint validates Codex stdin, resolves `cwd` as the repository root input, dispatches the relevant shared lifecycle decision, and translates only the result into Codex hook output.

Shared commands receive explicit repository paths and ordinary values. They do not read `PLUGIN_ROOT`, `CLAUDE_PROJECT_DIR`, Codex event fields, or hook event names. Claude adapters continue translating Claude inputs to the same commands.

Alternative considered: install `.codex/hooks.json` into every generated repository. Rejected because plugin-bundled hooks are native, centrally maintained, and avoid mutating user Codex configuration.

Alternative considered: point Codex directly at current Claude scripts. Rejected because `resolve_paths`, wrapper checks, event filtering, and output emission currently contain Claude-specific assumptions that would either misclassify a valid Codex layout or make shared behavior depend on compatibility environment variables.

### Share decisions, not runtime envelopes

Drift classification remains one executable authority. Codex and Claude adapters pass the same repository root, base/head range, and config, then render the returned route and evidence in their native output shapes. Codex confirms a Bash command is Git-related from `tool_input.command` before invoking the classifier. Malformed or non-Git event payloads stay silent; classifier uncertainty after confirmed Git activity nudges.

Startup shares a small layout decision that distinguishes canonical, legacy, and missing onboarding. Claude alone adds its `CLAUDE.md` import integrity check. Codex treats canonical `AGENTS.md` as valid and emits no body. Subagent behavior shares the bounded pointer text; each adapter wraps it for its event schema.

Alternative considered: copy existing drift and layout branches into Codex scripts. Rejected because equivalent inputs could diverge and maintenance would require two rule edits.

### Use only events that map directly to maintained behavior

Bundle:

- `SessionStart` for silent canonical-layout validation and missing/legacy reminders.
- `SubagentStart` for the bounded `AGENTS.md` pointer.
- `PostToolUse` matched to `Bash`, with a stdin Git-command gate before drift work.

Do not add `Stop`, `SubagentStop`, compaction, permission, or implementation-loop hooks. Codex natively reloads project instructions and current scope needs no diagnostics equivalent to Claude `InstructionsLoaded`.

Alternative considered: hook every tool that can change files. Rejected because drift state is commit-based; Git-related activity is the narrow deterministic trigger and broad tool hooks would add noise and process cost.

### Treat hook trust and disablement as expected fallback states

Plugin hooks remain non-managed and require Codex trust review. Documentation and live verification use `/hooks` to observe and trust the exact definition. Skills never interpret missing hook delivery as a workflow failure; runtime guidance states that users run `update-agent-onboarding` manually after meaningful commits when hooks are disabled, unavailable, or untrusted.

Alternative considered: require bypassing hook trust. Rejected because it weakens Codex's security boundary and is unnecessary for advisory behavior.

### Make capability claims executable

Keep `Hooks` in `.codex-plugin/plugin.json` only in the same change that adds its explicit hook path and packaged handlers. Extend manifest tests to resolve declared paths, parse hook JSON, verify referenced entrypoints/shared helpers, and reject Claude-only descriptions. Add deterministic adapter fixtures for every silence and signal branch, plus a separate live protocol because static tests cannot prove runtime delivery or trust behavior.

Alternative considered: document hooks without declaring them. Rejected because installed plugin metadata would under-report shipped functionality and automated packaging validation would remain incomplete.

## Risks / Trade-offs

- [Codex hook schemas evolve] → Keep event parsing in one adapter, pin fixture shapes to current official documentation, and make malformed events silent unless confirmed Git activity reached shared classification.
- [Codex runs from a subdirectory] → Use the event `cwd` as input and resolve the Git root before reading repository state.
- [Plugin hook update loses prior trust] → Treat review as expected, document `/hooks`, and retain manual lifecycle operation.
- [Windows lacks Bash] → Use the existing polyglot wrapper behavior and report hooks as unavailable while skills and native `AGENTS.md` loading continue.
- [Concurrent drift-hardening work changes classifier paths or output] → Integrate against its stable route contract and avoid merging a second classifier; sequence shared-core work before adapters.
- [PostToolUse fires often] → Match only `Bash`, self-gate on Git command input, and perform no Git or state reads for irrelevant activity.
- [Startup reminder becomes noisy in unmanaged repositories] → Emit only for missing or legacy onboarding, keep valid layouts silent, and let users disable or decline trust for plugin hooks.

## Migration Plan

1. Land or reconcile the runtime-neutral drift and layout decision commands, preserving existing Claude fixtures before adapter changes.
2. Add Codex hook configuration, entrypoint, event fixtures, and plugin packaging assertions without changing skill availability.
3. Update runtime-awareness text and verification docs to distinguish native Codex hooks, trust/disablement, and manual fallback.
4. Run shared-core, Claude regression, Codex adapter, manifest, and full repository tests.
5. Execute the live Codex protocol: install the plugin, review/trust hooks, verify a valid startup is silent, confirm native `AGENTS.md` canary context, inspect minimal subagent context, and compare relevant/irrelevant Git drift delivery.
6. Publish the `Hooks` capability only with recorded static proof and a verifiable live protocol. Rollback removes the Codex hook manifest entry and packaged adapter while leaving portable skills, state, onboarding files, and Claude hooks unchanged.

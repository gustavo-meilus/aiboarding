# aiboarding — Release Notes

> Canonical record of versioned changes, feature additions, and removals for the aiboarding project. This document tracks the build-out from the foundation release toward the full create → sync → update lifecycle.

<overview>
aiboarding onboards AI coding agents like fresh engineers: it maintains one compressed `AIBOARDING.md` per repository and uses committed hooks to inject it into every agent context and flag it when it drifts. The v0.1.0 foundation establishes the plugin scaffold, the cross-platform polyglot hook templates (the `sync` and `update` enforcement layer), and a dependency-free bash test harness. The generation (`create-aiboarding`) and triage (`update-aiboarding`) skills are designed and planned but not yet implemented.
</overview>

## v0.1.0 — Foundation: Plugin Scaffold & Hook Templates (2026-05-29)

### Highlights

First public release. It ships the deterministic enforcement layer — the hooks that load `AIBOARDING.md` into agents and detect drift — without yet shipping the skills that author the document. This sequencing is deliberate: the hooks are pure, unit-testable scripts that everything else installs, so they are built and proven first.

<release_entry version="0.1.0" status="FOUNDATION">

### What ships

- **Plugin scaffold** — `.claude-plugin/plugin.json` (`aiboarding` namespace).
- **Sync hooks** — `session-start` (SessionStart injection + missing-doc fallback) and `pre-task` (PreToolUse[Task] sub-agent injection).
- **Update hook** — `post-commit` (PostToolUse drift nudge comparing `last_synced_commit` to `HEAD`).
- **Polyglot wrapper** — `run-hook.cmd`, one file valid as both CMD and bash, with graceful Windows degradation when Git Bash is absent.
- **Shared library** — `_lib`: pure-bash JSON escaping, path resolution, frontmatter reading, and Claude Code hook-output emission.
- **Settings snippet** — `templates/settings/hooks.json` wiring all three hooks.
- **Test harness** — five dependency-free bash suites; all passing.
- **Design docs** — architecture umbrella + create/sync/update specs + three implementation plans under `docs/superpowers/`.

### The document contract

`AIBOARDING.md` carries drift state in frontmatter (`aiboarding_version`, `generated`, `last_synced_commit`) over three caveman-compressed sections: Engineering Basics, Domain & Business Logic, AI-Specific Context. `last_synced_commit` is the single drift signal consumed by `post-commit` and the planned `update-aiboarding`.

### Cross-platform model

Hooks run through a polyglot `run-hook.cmd`: on Windows, CMD locates Git Bash and dispatches; on POSIX, bash skips the CMD heredoc and runs the named script. Extensionless script names avoid Claude Code's Windows `.sh` auto-detection, and `.gitattributes` pins LF endings so shebangs and string comparisons survive Windows checkouts.

### Known limitations

- No user-facing skills/commands yet — `create-aiboarding`, `update-aiboarding`, and the hook installer are designed but unimplemented (v0.2.0–v0.3.0).
- `PreToolUse` sub-agent injection (`additionalContext`) is unverified against the live runtime; may switch to `updatedInput`.
- `PostToolUse` matcher is `Bash` (self-gated); narrowing to `git commit` deferred.
- Windows requires Git for Windows; absent it, injection no-ops silently.

</release_entry>

### Roadmap

- **v0.2.0** — `create-aiboarding`: hybrid background crawl + grilling interrogation → drafted `AIBOARDING.md` → caveman compression → Phase 6 installer that copies the hook templates into the target repo and idempotently merges the settings snippet.
- **v0.3.0** — `update-aiboarding`: commit-triggered triage of `<last_synced_commit>..HEAD`, auto-advancing the pointer on no-op changes and running a targeted-delta patch (scoped grill → synthesize → compress → approve) when scope drifts.

### Full changelog

See `CHANGELOG.md`.

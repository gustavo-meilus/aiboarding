---
name: cutting-a-release
description: Cut an aiboarding version release (vX.Y.Z) - verify the single version target agrees, draft matching CHANGELOG + RELEASE-NOTES entries, commit to main, then create the GitHub release + tag and verify. Use when the user asks to cut/ship/publish a release, tag a version, do release work, or write release notes for aiboarding.
---

# Cutting an aiboarding Release

Cut a version release after the feature work is merged into `main`. Full step detail + gotchas live in [RUNBOOK.md](RUNBOOK.md) - read it before acting.

## Hard constraints (read first)

- **`main` requires a pull request and its required checks.** Do not push release changes directly.
- **Exact-SHA CI evidence is required.** Before tagging, run `bash tools/verify-release-sha <target-sha>`; local checks do not replace it.
- **One version target.** Only `.Codex-plugin/plugin.json` (`version`) carries the version. `marketplace.json` has NO per-plugin version field - do not add one. There is no package.json / `.version-bump.json` / `.cursor-plugin` / AGENTS.md version.
- **JSON must be BOM-free.** Never `Set-Content -Encoding UTF8` for JSON. Use the Edit tool or `python3` writes (`encoding="utf-8"`).
- **Tag ↔ changelog convention** (stated in `CHANGELOG.md` header): every tag `vX.Y.Z` MUST have a matching `## X.Y.Z` CHANGELOG entry and a `## vX.Y.Z` RELEASE-NOTES entry before `gh release create`.
- **gh CLI in Bash tool:** never `--body @'...'@` (PowerShell here-string, fails). Write the body to a temp `.md`, use `--body-file`, then `rm` it. Keep temp files out of commits.
- **Title form:** `vX.Y.Z - <Title Case Feature Name>` (matches existing releases).

## Workflow

1. **Preflight** - `git fetch origin`; confirm `origin/main` has the feature merge; verify `plugin.json` `version` equals the intended vX.Y.Z; check tag/release naming convention.
2. **Sync local main** - `git checkout main && git pull --ff-only origin main`; set the explicit target with `target_sha=$(git rev-parse origin/main)` and run `bash tools/verify-release-sha "$target_sha"`.
3. **Bump version if needed** - if the feature work did not already bump `plugin.json`, do it now (Edit tool, BOM-free).
4. **Draft doc entries** - add `## X.Y.Z` to `CHANGELOG.md` (with trailing `---` separator) and a `<release_entry>` to `RELEASE-NOTES.md`, mirroring the previous entry's format exactly; extend the `<overview>` milestone sentence and the Roadmap. Source bullets from real changes; do not invent.
5. **Commit through a pull request** - `git add` the changed files, commit, open a pull request, and merge only after required checks pass. Refresh `target_sha` from `origin/main` and run `bash tools/verify-release-sha "$target_sha"` before tagging.
6. **Create release + tag** - extract the new CHANGELOG section as the release body, append the install line, `gh release create vX.Y.Z --target main --title "vX.Y.Z - <Title>" --notes-file <tmp>`.
7. **Verify** - tag commit == `origin/main`; release not draft/prerelease; it shows as `Latest`.

## Gotchas checklist

- [ ] Bumped `plugin.json` `version` only - did NOT add a version field to marketplace.json.
- [ ] `plugin.json` version == intended vX.Y.Z before tagging.
- [ ] CHANGELOG (`## X.Y.Z` + `---`) and RELEASE-NOTES (`<release_entry>` + overview + roadmap) entries exist before `gh release create`.
- [ ] Used `--body-file` for all gh bodies (never `@'...'@`).
- [ ] JSON edits BOM-free.
- [ ] Temp files cleaned up, kept out of commits.

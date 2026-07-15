# Release Runbook - aiboarding (full detail)

Repo: `C:\Users\gmeil\Github\aiboarding` (default branch `main`, **NOT** branch-protected). Platform: Win11 / PowerShell + Bash tool. Derived from the v0.1.x release series.

## Hard constraints (read before acting)

1. **`main` is NOT branch-protected.** Direct `git push origin main` succeeds. No PR, no `REVIEW_REQUIRED`, no `--admin` override. If the user prefers a PR for review, ask - but the default is push-to-main.
2. **No CI / no build / no test gate for release.** There is no `.github/workflows`. (The repo has a bash test harness under `tests/`, run manually with `tests/run.sh`; it is not a release gate.) Verification is `rg`/Read assertions + `python3 -c "import json; json.load(...)"`.
3. **Single version source of truth:** `.claude-plugin/plugin.json` (`version`). That is the ONLY synced version field. `marketplace.json` has NO per-plugin `version` key (do not add one - its plugin entry is `name`/`description`/`source`/`category` only). There is no `package.json`, no `.version-bump.json`, no `.cursor-plugin/plugin.json`, no CLAUDE.md project-version line.
4. **JSON must be BOM-free.** Never `Set-Content -Encoding UTF8` for JSON. Use the Edit tool or `python3` writes (`encoding="utf-8"`).
5. **Tag ↔ changelog convention** (stated in `CHANGELOG.md` header - "Each entry below corresponds to a git tag of the same name on `main`"): every tag `vX.Y.Z` MUST have a matching `## X.Y.Z` CHANGELOG entry and a `## vX.Y.Z` RELEASE-NOTES entry.
6. **gh CLI quirks:** `--body @'...'@` is PowerShell here-string syntax and FAILS in the Bash tool - write the body to a temp `.md` and use `--body-file`. A normal (non-draft/prerelease) release is `Latest` by default.
7. **Install line** (from CHANGELOG header): `/plugin marketplace add gustavo-meilus/aiboarding` then `/plugin install aiboarding@aiboarding`. Pin form: `/plugin install aiboarding@aiboarding --version vX.Y.Z`.

## Step-by-step: cut a release (vX.Y.Z)

Assumes the feature work is already on `main` (or about to be committed alongside the docs). The version bump may ship with the feature or as part of this release commit.

### 0. Preflight
- `git fetch origin --quiet`
- Confirm `origin/main` HEAD includes the feature work: `git log origin/main --oneline -3`.
- Confirm the version target equals the intended vX.Y.Z:
  `python3 -c "import json; print(json.load(open('.claude-plugin/plugin.json'))['version'])"`.
- Check existing tags/releases for the naming convention: `git tag --sort=-v:refname` and `gh release list --limit 5`. Title form is `vX.Y.Z - <Title Case Feature Name>`.

### 1. Sync local main
- `git checkout main` then `git pull --ff-only origin main`.

### 2. Bump the version (if not already done)
- If `plugin.json` `version` is not yet vX.Y.Z, bump it with the Edit tool (BOM-free). This is the only file to touch for the bump.

### 3. Draft the two doc entries (match existing format exactly)
- Read the most recent entry in each file to mirror structure:
  - `CHANGELOG.md`: `## X.Y.Z - Title (YYYY-MM-DD)`, a one-line summary, then `### Added` / `### Changed` / `### Known Limitations` (and `### Fixed` / `### Non-Goals` as applicable). Insert ABOVE the previous `## <prev>` heading, and end the new block with a `---` separator (entries are `---`-delimited).
  - `RELEASE-NOTES.md`: `## vX.Y.Z - Title (YYYY-MM-DD)`, a `### Highlights` paragraph, then `<release_entry version="X.Y.Z" status="...">` with `### Added` / `### Changed` / `### Known limitations` sections. Insert ABOVE the previous `## v<prev>` heading. Also: extend the `<overview>` paragraph's trailing milestone sentence with the new version, and update the `### Roadmap` section near the bottom.
- Use the Edit tool (anchored on the previous version heading). Date = today (convert any relative date to absolute ISO).
- Source bullet content from the real feature changes; do NOT invent.

### 4. Commit to main (no PR - main is open)
- `git add .claude-plugin/plugin.json CHANGELOG.md RELEASE-NOTES.md` (+ any feature files not yet committed).
- `git commit -m "docs(release): add X.Y.Z changelog + release-notes entries"` (or fold into the feature commit if bumping together).
- `git push origin main`.
- Verify landed: `rg -n "^## X.Y.Z" CHANGELOG.md` and `rg -n "^## vX.Y.Z" RELEASE-NOTES.md`.

### 5. Create the GitHub release + tag
- Extract the new CHANGELOG section as the release body:
  `awk '/^## X\.Y\.Z/{f=1;next} /^## [0-9]/{f=0} f' CHANGELOG.md > <tmp>` (stops at the next `## <version>` heading), then append an install line:
  `**Install:** /plugin install aiboarding@aiboarding --version vX.Y.Z`.
- `gh release create vX.Y.Z --target main --title "vX.Y.Z - <Title>" --notes-file <tmp>`; `rm` the tmp.
  (This creates the tag `vX.Y.Z` on the current main HEAD.)

### 6. Verify
- `git fetch origin --tags --quiet`; assert `git rev-list -n1 vX.Y.Z` == `git rev-parse origin/main`.
- `gh release view vX.Y.Z --json tagName,targetCommitish,isDraft,isPrerelease` (expect not draft/prerelease).
- `gh release list --limit 3` - new release shows `Latest`.

## Gotchas checklist (quick)
- [ ] Bumped `plugin.json` `version` ONLY - did not add a version key to marketplace.json.
- [ ] Version target == intended vX.Y.Z before tagging.
- [ ] CHANGELOG (`## X.Y.Z` + `---`) and RELEASE-NOTES (`<release_entry>` + overview + roadmap) entries exist before `gh release create`.
- [ ] Used `--body-file` for all gh bodies (never `@'...'@` in the Bash tool).
- [ ] JSON edits BOM-free.
- [ ] Temp files (`.rel-notes.md`, etc.) cleaned up - kept OUT of commits.

## Reference (v0.1.x series)
- Tags `v0.1.0`–`v0.1.3`, all on `main`, all dated 2026-05-29. Titles: `v0.1.3 - Distribution & Verification Runbook`, `v0.1.2 - update-aiboarding Skill`, etc.
- CHANGELOG entries `---`-delimited; RELEASE-NOTES uses `<release_entry version status>` blocks plus an `<overview>` milestone sentence and a trailing `### Roadmap`.

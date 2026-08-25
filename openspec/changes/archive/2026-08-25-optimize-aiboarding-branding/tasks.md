## 1. Establish Brand Truth

- [x] 1.1 Inventory README, manifest, release, compatibility, safety, installation, and benchmark claims against executable tests and retained v0.6.0 evidence; verify every public claim has a source and qualification or is removed.
- [x] 1.2 Create the concise `docs/BRAND.md` source sheet with the approved position, promise, onboarding-drift term, voice, palette, asset inventory, exact GitHub description/topics, and unchecked administrator metadata steps; verify it contains no unsupported capability, response-time, or release promise.
- [x] 1.3 Replace stale or duplicated version/status wording with v0.6.0-aligned or non-hard-coded wording; verify README, Claude/Codex manifests, changelog, and release references agree through the focused branding check.

## 2. Complete the Visual Asset Family

- [x] 2.1 Render `assets/aiboarding-icon.svg` on light and dark backgrounds at full and 32 px sizes, make only demonstrated contrast/silhouette refinements, and verify the master remains self-contained and recognizable.
- [x] 2.2 Derive self-contained `assets/aiboarding-wordmark-light.svg` and `assets/aiboarding-wordmark-dark.svg` from the approved mark; verify XML parsing, absence of scripts/external references, theme contrast, and exact mark consistency.
- [x] 2.3 Build `assets/aiboarding-demo.svg` from a real lifecycle fixture or command transcript and record the source; verify the displayed input/output matches repository behavior and the README explanation states what the demo does and does not prove.
- [x] 2.4 Render `assets/aiboarding-icon-512.png` and a flattened `assets/aiboarding-social-preview.png` from the approved vector composition; verify PNG signatures, 512x512 and 1280x640 dimensions, social-card size below 1 MB, solid background, and legibility at intended sizes.

## 3. Rebuild the Public Story

- [x] 3.1 Rewrite the README hero, problem, “See it,” and quick-start sections around the approved position and shortest currently supported Claude install; verify a first-time reader reaches a tested first action before architecture or repository inventory.
- [x] 3.2 Add proof/limitations, lifecycle workflow, safety/non-goals, and supported-surface sections using existing tests and retained evidence; verify each claim links to its source and distinguishes automated, live-verified, portable, degraded, and unavailable states.
- [x] 3.3 Compress and reorder existing architecture, cross-agent install, roadmap, documentation, contribution, security, and license material without losing authoritative boundaries; verify all original behavior/limitation links remain represented and remove the star-history section as proof.
- [x] 3.4 Embed the theme-aware hero and representative demo with useful alt/equivalent text and one factual final CTA; verify GitHub-compatible relative paths and light/dark README rendering.
- [x] 3.5 Align `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, and `.codex-plugin/plugin.json` with the approved audience, outcome, mechanism, and asset paths; verify `bash tests/plugin/test-manifests.sh` and `claude plugin validate . --strict` pass.

## 4. Complete the Community Front Door

- [x] 4.1 Add focused `CONTRIBUTING.md` and `CODE_OF_CONDUCT.md` files that reuse existing test, security, and review rules without inventing support or response-time guarantees; verify README navigation reaches both files.
- [x] 4.2 Add bug and feature-request issue forms plus `.github/pull_request_template.md` with intent, impact, verification, and safety prompts; verify required form keys and referenced commands/links through the branding check.
- [x] 4.3 Link help, issue intake, contribution, conduct, `SECURITY.md`, and `LICENSE` from the README; verify local link resolution and that vulnerabilities still route privately rather than to a public issue.

## 5. Prove and Hand Off

- [x] 5.1 Add `tests/docs/test-branding.sh` to validate required assets, SVG portability, PNG dimensions/size, README local links, manifest asset resolution, positioning markers, and version consistency; verify focused positive checks pass and temporary missing-asset, wrong-dimension, broken-link, and divergent-version cases fail with named diagnostics.
- [x] 5.2 Run `bash tests/docs/test-branding.sh`, `bash tests/plugin/test-manifests.sh`, `bash tests/run.sh`, `claude plugin validate . --strict`, and `git diff --check`; verify every command passes without changing runtime or generated onboarding behavior.
- [x] 5.3 Render and visually inspect every final vector and raster asset at original and avatar sizes on light and dark backgrounds, test README installation commands verbatim, and verify the review records limitations rather than treating mechanical checks as visual proof.
- [x] 5.4 Compare `docs/BRAND.md` target metadata with `gh repo view`, leave unperformed GitHub description/topic/social-preview actions explicitly unchecked, and hand the exact administrator steps to the maintainer without publishing a release or claiming activation.

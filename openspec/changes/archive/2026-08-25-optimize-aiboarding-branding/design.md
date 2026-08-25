## Context

See `proposal.md` for motivation and `specs/repository-branding/spec.md` for the public contract. The current release and both plugin manifests are v0.6.0, while the README still presents a v0.5.0 status badge and paragraph. The README already contains the strongest reusable language—“keeps AGENTS.md alive,” “onboard AI agents like fresh engineers,” and the lifecycle model—but leads with dense inventory, never displays the existing icon, lacks a representative demo and proof section, and ends with a low-value star-history block.

`assets/aiboarding-icon.svg` is a self-contained square document/route/check mark using navy, teal, and blue. The Claude and Codex manifests already point to the repository root and carry broadly compatible descriptions. Official OpenAI plugin path guidance requires manifest paths to be plugin-root-relative with `./` and recommends `./assets/` for `composerIcon` and `logo`, so the current Codex asset location can remain canonical rather than being copied under `.codex-plugin/` ([OpenAI Docs](https://developers.openai.com/plugins/build/plugins#path-rules)).

The repository has `SECURITY.md` and `LICENSE`, but not focused contribution, code-of-conduct, issue-form, or pull-request guidance. GitHub metadata is already populated and the latest release is v0.6.0, but social-preview activation cannot be performed through a repository commit. GitHub README rendering permits only portable markup; all final assets must work without scripts, CSS, network-loaded fonts, or sibling-file embedding.

## Goals / Non-Goals

**Goals:**

- Make one truth-backed message and visual metaphor recognizable across README, plugin listings, repository metadata, and assets.
- Give first-time visitors a demonstration-first path to a tested install and bounded proof.
- Complete only the community-health files needed to make help, contribution, conduct, security, and review routes explicit.
- Keep brand artifacts portable, accessible, mechanically inspectable, and cheap to maintain.

**Non-Goals:**

- Rename AIBoarding, create a mascot, commission a website, add a docs framework, or introduce a new font or runtime dependency.
- Change onboarding behavior, host compatibility, security boundaries, benchmark methods, package distribution, versioning, or release state.
- Run new cost-bearing benchmarks or turn current pilot evidence into a general performance claim.
- Add `GOVERNANCE.md` or a standalone `SUPPORT.md` before multiple maintainers or recurring support load make those files useful.
- Mutate GitHub settings, publish a release, or claim external metadata activation from the implementation workflow.

## Decisions

### 1. Lock product truth before writing promotional copy

Implementation starts with a claim ledger built from current tests, manifests, v0.6.0 release records, verification documentation, and retained benchmark artifacts. The ledger can remain implementation evidence rather than a new permanent subsystem; only claims that survive it appear publicly. Current version wording is centralized or made dynamic where practical so the README does not drift from manifest releases again.

Alternative considered: rewrite the hero first and qualify claims later. Rejected because it repeats the stale v0.5.0 contradiction and makes visual polish amplify unverified copy.

### 2. Use the existing language and mark as the brand core

The precise position is: “AIBoarding is a repository onboarding lifecycle for maintainers using AI coding agents that creates and keeps canonical `AGENTS.md` guidance current across supported agents, without duplicated instruction sources or broad rewrites of unchanged guidance.” The memorable promise is “A current boarding pass for every coding agent,” backed by the existing “keeps `AGENTS.md` alive” line. The named failure mode is the already-real “onboarding drift,” not a newly invented fear term.

The existing icon is refined only where small-size or contrast inspection demonstrates a problem. Its document is the boarding pass, its route mark represents entering and navigating a repository, and its check represents current, verified guidance. Navy remains the technical base; teal and blue remain the action/verification colors; neutral light and dark surfaces supply theme contrast. Typography uses system sans-serif fallbacks and asset lettering is converted to paths or flattened where renderer variance matters.

Alternative considered: generate a mascot and entirely new palette. Rejected because the current mark already fits the product and a mascot would add originality, consistency, and maintenance work without solving a demonstrated recognition problem.

### 3. Derive every asset deterministically from one approved mark

Keep `assets/aiboarding-icon.svg` as the master and produce only the required family:

- `assets/aiboarding-icon-512.png` for compact raster consumers;
- `assets/aiboarding-wordmark-light.svg` and `assets/aiboarding-wordmark-dark.svg` for theme-aware README use;
- `assets/aiboarding-demo.svg` from a real lifecycle fixture or command transcript, with equivalent explanatory text in the README;
- `assets/aiboarding-social-preview.png`, flattened at 1280x640 on a solid background.

SVGs are self-contained XML with no scripts, network resources, external fonts, or `<image href>` references. Raster outputs are rendered from approved vector composition rather than independently generated, so the mark does not drift between assets. Each file includes or is paired with meaningful accessible text.

Alternative considered: embed the square icon into sibling SVGs by relative reference. Rejected because renderer portability is inconsistent and the playbook records a concrete blank-render failure for that pattern.

### 4. Rebuild the README around one visitor journey and delete low-signal content

The new order is hero and compact navigation; why/onboarding drift; “See it”; quick start; proof and limitations; lifecycle workflow; safety/non-goals; supported surfaces; concise architecture; documentation map; contributing/security/license; one in-character CTA. Existing detailed lifecycle, architecture, install, roadmap, and cross-agent material is reused and compressed into those sections rather than duplicated. The repository layout moves behind the architecture explanation or to a deep link. The star-history chart is removed; stars may remain as one truthful badge or final CTA, not as proof.

The proof section links the existing deterministic test suite, verification protocols, and retained v0.6.0 benchmark report. It separates implementation proof, live-runtime status, and bounded pilot observations; it makes no general speed, token, or quality claim.

Alternative considered: preserve the current section order and add a hero banner. Rejected because decoration would not fix the inventory-first adoption path.

### 5. Keep one source message with length-specific copies

`docs/BRAND.md` becomes a short maintained sheet containing the precise position, short promise, failure term, voice, palette, asset inventory, target GitHub description/topics, and manual social-preview upload instruction. README, Claude marketplace, Codex interface, and GitHub metadata draw from that sheet but use surface-appropriate lengths; they are not forced into byte-identical prose.

Manifest paths remain relative to the plugin root. The deterministic check resolves each declared local asset path and verifies that marketplace descriptions retain the audience, outcome, and current lifecycle vocabulary.

Alternative considered: introduce a generator that emits all copy from structured configuration. Rejected because four short human-facing surfaces do not justify code generation or a new configuration format.

### 6. Add the smallest complete community front door

Add `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, focused GitHub issue forms for bugs and feature requests, and `.github/pull_request_template.md`. Reuse `SECURITY.md` and `LICENSE`; do not duplicate their content. The README links each route and states where general help belongs. Governance and standalone support documents remain deferred until real project structure or demand requires them.

Alternative considered: add every community-profile file listed in the playbook. Rejected because governance and formal support promises would be speculative for the current project.

### 7. Put all brand regression proof in one discovered test

Add one `tests/docs/test-branding.sh`, automatically discovered by `tests/run.sh`. It uses Bash plus Python standard-library parsing to verify required files, SVG XML and forbidden external references, PNG signatures/dimensions/size, README local links, social-preview dimensions, manifest path resolution, release/version consistency, and required positioning markers. Existing `tests/plugin/test-manifests.sh` remains responsible for general manifest and plugin contracts; only a narrowly missing manifest assertion should be added there if ownership is clearer than duplicating it.

Mechanical checks are followed by original-size and avatar-size render inspection on light and dark backgrounds. The manual check records what was inspected but does not add screenshots or visual snapshots to the normal test suite.

Alternative considered: add a visual-regression framework. Rejected because static brand assets need a small structural check and human review, not a new image-testing dependency.

## Risks / Trade-offs

- [The boarding-pass phrase could sound like travel software without factual context] → Keep the precise repository-onboarding category sentence adjacent to the promise on every prominent surface.
- [A full README rewrite could discard useful technical detail] → Reuse current content, compare all existing headings and links, and move depth rather than silently deleting authoritative behavior or limitations.
- [Benchmark copy could overgeneralize limited pilot evidence] → Lead with deterministic functional proof, link raw evidence, state sample and runtime limitations beside any observation, and omit numbers that cannot be reproduced from retained artifacts.
- [SVGs can render differently across GitHub themes and tools] → Use self-contained shapes, no external references, theme-specific variants, mechanical XML checks, and visual inspection at original and avatar sizes.
- [Repository metadata can drift after the files merge] → Record exact target values and an unchecked administrator checklist in `docs/BRAND.md`; verify the live repository separately.
- [New community files create expectations] → Keep contribution and issue guidance factual and avoid response-time, governance, or support guarantees the maintainer has not committed to.

## Migration Plan

1. Capture the pre-change claim and link inventory, then update copy and assets without touching runtime behavior.
2. Land the master-derived asset family and deterministic branding check.
3. Reorder the README, align manifests, add the minimal community files, and run focused checks followed by `bash tests/run.sh` and `claude plugin validate . --strict`.
4. Render and inspect every asset, test README links and installation commands verbatim, and compare public claims against v0.6.0 evidence.
5. After merge, a maintainer applies and verifies the documented GitHub description/topics/social-preview settings. Rollback is a normal revert of documentation/assets; no data or compatibility migration is required.

# Open-Source Repository Marketing, Branding, and Launch Playbook

Last updated: 2026-08-24

## Purpose

This playbook turns a technically complete repository into a product people can understand, trust, install, remember, and recommend.

It is based on the research and execution used to reposition and launch **Gunk Buster**, combined with current GitHub, npm, OpenSSF, SLSA, and CHAOSS guidance; recent empirical research on open-source documentation, community health, supply-chain security, and AI-assisted development; and pattern analysis of successful developer-tool repositories including [Superpowers](https://github.com/obra/superpowers), [Ponytail](https://github.com/DietrichGebert/ponytail), and [Superpipelines](https://github.com/gustavo-meilus/superpipelines).

Use it when:

- a repository has outgrown its original README;
- implementation is real but the public story still sounds speculative;
- a project needs recognizable branding without looking like a consumer-product landing page;
- benchmarks or proof artifacts exist but are not yet communicated responsibly;
- a package is approaching its first public release;
- maintainers want a repeatable launch process rather than a one-off README rewrite.

The central idea is simple:

> A repository launch is not a documentation task. It is the alignment of product truth, positioning, proof, identity, distribution, safety, and contributor trust.

---

## 1. The operating model

A strong open-source launch has six connected surfaces:

| Surface | Question it answers |
| --- | --- |
| Product truth | What actually exists, works, and remains limited? |
| Positioning | Who is this for, what pain does it remove, and why this solution? |
| Branding | What makes the project recognizable and emotionally distinct? |
| README | Can a visitor understand, trust, and try it within minutes? |
| Proof | What evidence supports the claims, and where are the limitations? |
| Distribution | Can users install, verify, update, report problems, and follow releases safely? |

Weak launches optimize one surface in isolation. Common examples are a beautiful README with broken installation, a package with no positioning, or a bold benchmark claim with no reproducible method.

The launch is ready only when the surfaces agree.

### The truth hierarchy

When sources disagree, use this order:

1. Executable behavior and tests
2. Shipped package or plugin contents
3. Current configuration and manifests
4. Architecture decisions and specifications
5. Supporting documentation
6. README marketing copy
7. Old planning material and issue discussions

Marketing must move toward implementation truth. Never bend product truth toward old marketing copy.

---

## 2. Phase zero: perform a release-truth audit

Do not begin by rewriting the hero section. First establish what can be claimed.

### Audit the repository

Inspect:

- current branch and worktree state;
- package and plugin manifests;
- executable entry points;
- built artifacts;
- installation paths;
- test and certification records;
- supported platforms;
- security and mutation boundaries;
- open issues that qualify a public claim;
- README, agent instructions, roadmap, ADRs, and specifications;
- registry state, staged-publication state, and release state;
- repository rulesets, required checks, and tag protections;
- GitHub Actions permissions, third-party action pinning, and publishing credentials;
- artifact provenance, attestations, checksums, and SBOMs when applicable;
- secret scanning, dependency review, and vulnerability-reporting configuration;
- repository description, topics, social preview, and community profile.

Create a claim ledger:

| Candidate claim | Evidence | Qualification | Public wording |
| --- | --- | --- | --- |
| Works on platform X | Test or manual transcript | Certified only on a named OS/version | “Verified on Windows 11” |
| Tool is read-only | Structural permission/code review | Confirm every code path | “Five read-only MCP tools” |
| Improves performance | Repeated benchmark | Model-, effort-, and workload-dependent | “Observed in this experiment,” not “always faster” |
| Available on npm | Registry lookup and install | Package must actually exist | Advertise source install until publication |

### Correct stale authority before amplifying the project

Gunk Buster exposed a representative failure: its supplied `AGENTS.md` still called the project “pre-code” even though the repository already contained a working CLI, MCP server, plugins, skills, hooks, tests, and built output. The public launch first corrected that stale authority.

This matters because visitors and coding agents both use repository instructions as truth. A polished README cannot compensate for authoritative files that contradict it.

### Treat agent instructions as a production interface

By 2026, repository-local AI instructions are no longer an experimental side file. GitHub Copilot supports repository-wide instructions in `.github/copilot-instructions.md`, path-specific instructions under `.github/instructions/`, and agent instructions in `AGENTS.md`; support varies by Copilot surface, and some agent environments also recognize `CLAUDE.md` or `GEMINI.md`. GitHub's current guidance recommends keeping build, test, project-structure, and engineering conventions in these files so agents spend less time rediscovering repository facts ([GitHub custom instructions](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions-in-your-ide/add-repository-instructions-in-your-ide), [custom-instructions support matrix](https://docs.github.com/en/copilot/reference/custom-instructions-support)).

Rules:

- keep one canonical source of truth for commands and invariants, then reference or summarize it in tool-specific files;
- avoid contradictory instructions across `AGENTS.md`, Copilot instructions, `CLAUDE.md`, and `GEMINI.md`;
- scope path-specific instructions only where they materially differ;
- keep instructions short enough that important rules are not buried;
- test instructions against a fresh checkout or agent environment;
- review agent instructions whenever build, test, release, security, or directory structure changes.

Treat these files like executable documentation: stale instructions can create bad patches, invalid reviews, unsafe commands, or wasted agent exploration even when the README is correct.

### Test safety claims structurally

During Gunk Buster's review, the docs called all MCP tools read-only, but `gunk_verify` could execute repository-configured shell commands. The MCP metadata even declared `readOnlyHint: true`.

The correct response was not to soften the marketing. The implementation was changed so MCP verification suppresses configured commands while the explicitly invoked CLI retains them. A regression test proved that an MCP call could not create a marker file.

Rule:

> If a safety promise can be made structurally true, enforce it in code before publishing the promise.

---

## 3. Position the repository before designing it

### Write the positioning sentence

Use this formula:

> **[Project] is a [category] for [specific audience] that [specific outcome] by [distinct mechanism], without [important rejected trade-off].**

Gunk Buster's working position became:

> A local, deterministic context-hygiene tool for AI coding agents that finds stale or misleading repository material before agents act on it, without code analysis, cloud processing, telemetry, numeric scoring, or automatic deletion.

The README shortened this into a memorable promise:

> Find hallucination bait before agents eat it.

The long sentence provides precision. The short sentence provides recall. Keep both.

### Name the enemy

Strong developer-tool narratives give a concrete name to an existing pain:

- Gunk Buster: **hallucination bait**
- Ponytail: over-engineering and unnecessary code
- Caveman: verbose agent output
- Superpipelines: uncontrolled coding loops and review theater
- Superpowers: ad-hoc agent development without disciplined methodology

The enemy should be:

- already experienced by the target user;
- specific enough to recognize;
- explainable without proprietary vocabulary;
- connected directly to the product mechanism.

Do not manufacture fear. Name a real failure mode and show it.

### Build a differentiation table privately

Before writing public comparisons, map competitors across checkable axes:

| Axis | This project | Alternative A | Alternative B |
| --- | --- | --- | --- |
| Primary job |  |  |  |
| Mechanism |  |  |  |
| Installation |  |  |  |
| Trust boundary |  |  |  |
| Supported hosts |  |  |  |
| Mutation behavior |  |  |  |
| Evidence quality |  |  |  |
| Explicit non-goals |  |  |  |

Only publish comparisons that are narrow, factual, respectful, and sourceable. Superpipelines does this effectively by praising adjacent frameworks before comparing two concrete axes: reviewer isolation and portability.

### Define the audience as a job, not a demographic

Use:

> This helps **[person in situation]** who is trying to **[job]** but currently suffers **[failure/cost]**.

Example:

> This helps maintainers using AI coding agents who need those agents to understand a repository without being misled by stale docs, copied instructions, or generated residue.

The [Open Source Guides](https://opensource.guide/finding-users/) recommends first clarifying what the project does, why it matters, and who benefits, then going to the communities where that audience already participates instead of broadcasting indiscriminately.

---

## 4. Learn patterns without cloning a competitor

The reference repositories reveal reusable patterns, not a template to copy verbatim.

### Superpowers: confidence through simplicity and automatic behavior

Observed pattern:

- immediate category statement;
- quick start near the top;
- prose that explains the workflow as a user journey;
- automatic activation as a central benefit;
- philosophy and methodology reinforce the product;
- installation is broken down by host;
- evidence-over-claims is part of the project's identity.

Lesson: if the product changes behavior automatically, explain the experience before cataloging components.

### Ponytail: character, before/after, and corrected benchmarks

Observed pattern:

- distinctive mascot and voice;
- one-line character premise;
- benefit metrics immediately visible;
- before/after example requiring almost no explanation;
- benchmark graphic, compact table, method, reproduction path, and limitations;
- older weaker evidence is preserved but demoted;
- a criticism of the earlier baseline is acknowledged and corrected.

Lesson: a strong personality and rigorous qualification can coexist. Correcting an inflated claim increases trust.

### Caveman: the README performs the product

Observed pattern:

- the prose itself demonstrates the terse voice;
- the rock emoji and deliberately simple language create instant recall;
- before/after is the primary demonstration;
- installation is short and prominent;
- benchmarks include raw data and reproduction assets;
- ecosystem projects share a consistent naming philosophy;
- the call to star the project stays in character.

Lesson: the README should embody the product's behavior when possible. Brand voice is more convincing when demonstrated than described.

### Superpipelines: technical authority and explicit boundaries

Observed pattern:

- opens with a differentiated technical promise;
- calls out structural enforcement rather than prompt convention;
- tells the truth when a host cannot enforce the same boundary;
- supports a broad platform matrix without pretending every platform is equivalent;
- uses diagrams, workflow tables, capability narratives, comparisons, and progressive documentation;
- cross-links sibling products to build an ecosystem story.

Lesson: for infrastructure products, credibility comes from explaining exactly where guarantees hold and where they degrade.

### The composite strategy

The Gunk Buster launch combined:

- Ponytail's memorable character and proof discipline;
- Caveman's demonstration-first communication;
- Superpowers' workflow-first explanation;
- Superpipelines' structural-boundary honesty;
- the maintainer's own preference for clear technical depth, matrices, and explicit limitations.

The result was similar in strategy, not appearance.

### 2026 pattern: distribution is becoming host-native

The reference projects have continued moving beyond a repository-only install story. Superpowers now documents host-specific installation across a broad set of coding-agent environments, while Ponytail has added native plugin surfaces, MCP distribution, npm packaging, and provenance-backed trusted publishing ([Superpowers README](https://github.com/obra/superpowers/blob/main/README.md), [Ponytail releases](https://github.com/DietrichGebert/ponytail/releases)).

The reusable lesson is not "support every host." It is:

- treat the repository as the canonical trust and documentation hub, not necessarily the only installation surface;
- make the primary adoption path native to the environment where users already work;
- keep host-specific install/update/remove instructions independently testable;
- expose the same product truth and safety boundaries across CLI, plugin, MCP, marketplace, and package-registry surfaces;
- publish through native trusted channels when they improve verification or reduce credential risk;
- avoid claiming parity when one host cannot enforce the same behavior or security boundary.

A repository can have excellent positioning and still lose adoption if the user must leave their normal toolchain to install or update it.

---

## 5. Build a brand system, not a decorative logo

### Start with the product metaphor

A useful open-source brand converts the mechanism into a visual story.

For Gunk Buster:

- stale context became a **digital zombie**: old material returning and causing damage;
- containment represented local, controlled handling;
- Markdown, broken links, chat fragments, and code symbols identified the domain;
- navy communicated technical seriousness;
- mint communicated detection and cleanup;
- coral provided a warning accent;
- the character remained playful rather than grotesque.

This created a recognizable mascot without compromising developer credibility.

### Keep inspiration legally and creatively distant

Subtle genre inspiration can guide energy, but the result must remain original.

For the zombie mark, the brief explicitly avoided:

- copyrighted characters;
- copied poses or wordmarks;
- the Ghostbusters ghost;
- the red circle-and-slash composition;
- gore or realistic decay;
- generic cleaning-company symbols.

Use inspiration to select tone—playful containment, monster-hunting energy, strong silhouette—not protected expression.

### Logo brief template

```text
Design a professional 1:1 identity mark for [PROJECT], a [CATEGORY]
that helps [AUDIENCE] achieve [OUTCOME].

Core metaphor: [VISUAL STORY CONNECTED TO PRODUCT MECHANISM].
Personality: [3-5 ADJECTIVES].
Intended uses: GitHub avatar, README hero, package page, plugin badge,
social card, favicon, terminal-adjacent documentation.

Style: clean, vector-friendly, recognizable at small sizes, restrained detail,
strong silhouette, credible for a developer audience.

Palette: [PRIMARY], [SECONDARY], [ACCENT], with strong light/dark contrast.
Composition: centered 1:1 mark with generous padding; symbol-first.

Avoid: copyrighted characters, copied brand structures, illegible text,
generic category clichés, photorealism, busy backgrounds, and details that
collapse at 32 px.
```

### Required asset matrix

| Asset | Recommended role |
| --- | --- |
| Square master mark | Source identity and GitHub avatar |
| 512 px optimized mark | Efficient README and package use |
| Light wordmark/hero | README on light theme |
| Dark wordmark/hero | README on dark theme |
| 1280×640 social preview | Shared repository links |
| Terminal/demo visual | Product mechanism |
| Optional favicon/icon | Docs site or executable ecosystem |

Every informative image needs useful alt text. GitHub recommends relative image paths for repository portability and supports theme-specific images through HTML/picture patterns. GitHub also truncates README content beyond 500 KiB, so keep markup compact and place large explanations in supporting docs ([GitHub README guidance](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes)).

### Compose deterministically after selecting the mark

Once a final logo exists, do not repeatedly regenerate it to create every asset. Preserve the exact mark and compose deterministic variants around it:

- pair the raster mark with code-native SVG wordmarks;
- derive a coherent palette from the mark;
- recolor demos and badges to the same palette;
- create both light and dark hero treatments;
- flatten the social card to a standalone PNG;
- inspect every output visually at original size;
- test at small avatar size;
- verify XML and image dimensions mechanically.

Important implementation lesson: embedding a sibling PNG inside an SVG is not portable across all renderers. During Gunk Buster's branding pass, the SVG rendered with a blank mascot in one tool. The robust solution was to render the mascot directly in README HTML, keep the theme-aware wordmark separate, and flatten the social preview into a self-contained PNG.

### Social preview is repository metadata

Committing `social-preview.png` does not activate it. A repository administrator must upload it in GitHub under **Settings → Social preview → Edit → Upload an image**.

GitHub recommends PNG, JPG, or GIF under 1 MB, at least 640×320, with 1280×640 preferred. A solid background is safest across platforms. See [GitHub's social-preview documentation](https://docs.github.com/en/enterprise-cloud@latest/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/customizing-your-repositorys-social-media-preview).

---

## 6. Engineer the README as a conversion path

The README should support several readers without forcing all of them through the same depth.

### The five-minute visitor journey

1. **Recognize** — What is this and is it relevant?
2. **Believe** — Can I see the problem and product behavior?
3. **Try** — What is the shortest correct installation path?
4. **Trust** — What evidence and safety boundaries exist?
5. **Explore** — Where are architecture and full references?
6. **Join** — How do I report, contribute, follow, or share?

### Recommended README structure

#### 1. Hero

Include:

- logo or mascot;
- project name;
- one-line promise;
- one or two lines of category explanation;
- only truthful badges;
- compact navigation to the sections readers need most.

Do not open with a wall of badges, internal architecture, or origin history.

#### 2. Problem framing

Describe the user's failure mode in their language. Introduce the memorable term only after the recognizable problem.

#### 3. “See it” demonstration

Show one representative input and output:

- a before/after;
- a terminal recording or static fallback;
- a compact screenshot;
- a real fixture-derived example.

Explain what the demo proves and what it does not do.

#### 4. Quick start

Lead with the adoption path most aligned with the product strategy. Gunk Buster used **plugin-first** installation because agent integration is the differentiated experience, while keeping CLI installation visible for approved mutations.

Every command must be tested exactly as written.

#### 5. Proof, not promises

Place the strongest functional evidence before performance observations. Link raw methods and artifacts.

#### 6. Workflow

Show the smallest end-to-end mental model. Text diagrams and short command maps are effective when they expose sequence.

#### 7. Safety and non-goals

Use a “does / does not” table. Explicit exclusions communicate product maturity and prevent feature requests that violate the design.

#### 8. Surface or compatibility matrix

Separate implemented, verified, certified, portable, experimental, and waived states. Do not collapse them into a generic checkmark.

#### 9. Architecture

Keep the top-level model in the README. Move deep design decisions into ADRs and specifications.

#### 10. Documentation map

Link to task-oriented supporting docs rather than duplicating them.

#### 11. Contribution, security, license, CTA

Tell readers where to report bugs, where not to report vulnerabilities, how to contribute, and how the project is licensed. End with one appropriate action: try it, star it, share a result, or open feedback.

### README quality rules

- Lead with user value, not implementation inventory.
- Put the first successful action before architecture.
- Use headings that answer questions.
- Keep paragraphs short.
- Make every badge carry decision value.
- Prefer tables for comparisons and matrices, not ordinary prose.
- Pair visuals with accessible text.
- Use relative links for repository files.
- Never advertise an installation path that is not currently available.
- Distinguish “works in automated tests” from “manually certified.”
- Keep claim limitations next to the claim.
- Link deep evidence instead of hiding it.

GitHub's own guidance says a README should explain what the project does, why it is useful, how to get started, where to get help, and who maintains it. It also describes README, license, contribution guidelines, and code of conduct as a set that communicates expectations ([GitHub README guidance](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes)).

Recent research reinforces that documentation is adoption infrastructure rather than cosmetic polish. A 2024 empirical study of practitioners identified the role of OSS documentation in adoption decisions and the adoption-relevant criteria practitioners seek, while also highlighting recurring problems around findability, technical terminology, examples, and references ([Imani et al., 2024](https://arxiv.org/abs/2403.03819)). A 2025 large-scale study of Debian-packaged projects found that `CONTRIBUTING` guidance is often added only after contribution activity increases, suggesting that projects commonly underinvest in contributor-facing documentation until the need is already visible ([Gaughan et al., 2025](https://arxiv.org/abs/2502.18440)).

Practical implication: write user and contributor onboarding before launch traffic arrives. Do not wait for repeated issues or a contributor spike to reveal that the repository lacks basic process documentation.

---

## 7. Turn benchmarks into proof without turning them into hype

### Build a claim ladder

| Evidence level | What it supports |
| --- | --- |
| Unit/integration tests | Implementation behavior |
| Installed-package smoke test | Distribution works outside the source tree |
| Functional activation test | The integration changes observable behavior |
| Single matched pair | Directional observation under tightly matched conditions |
| Repeated/interleaved experiment | More credible performance comparison |
| Multi-model/multi-repo study | Broader, still bounded generalization |

Never use a lower evidence level to imply a higher claim.

### Separate functional proof from performance proof

Gunk Buster needed to answer two different questions:

1. **Activation:** Does the unnamed prompt cause the installed plugin to invoke a Gunk-managed tool?
2. **Performance:** Does tool exposure or context cleanup change time or token usage beyond run-to-run noise?

One successful, mechanically recorded MCP call can prove functional activation. It cannot prove average performance.

### Budget the benchmark before executing it

Estimate cumulative billed input, not final context-window occupancy.

The critical Gunk Buster lesson was a mistaken cost estimate. A historical “61.2K context used” figure was treated like total input, but a real medium-effort run consumed roughly 320K–410K cumulative input tokens. The mistaken assumption underestimated cost by about five times.

Before any agent benchmark, write:

| Variable | Estimate |
| --- | ---: |
| Runs |  |
| Input per run |  |
| Uncached input per run |  |
| Output per run |  |
| Wall time per run |  |
| Total expected usage |  |
| Abort threshold |  |

If the user has a quota constraint, prefer mining existing artifacts, scoring saved answers, or using zero-model mechanical probes before adding runs.

### Validity gates must fail before model contact

One Gunk Buster benchmark silently measured the wrong condition because the automation shell could not resolve `node`, so Codex could not start the plugin's MCP server. The agent still produced a plausible answer and exited successfully.

The corrected harness:

- sources NVM when necessary;
- verifies `node` resolves before a post-plugin run;
- exits with a dedicated invalid-run code before contacting the model;
- treats actual `mcp_tool_call` events as exposure evidence.

Do not trust a model's self-report of its available tools. In the diagnostic probe, the model reported no tools even when the tool was callable. Mechanical traces are authoritative.

### Preserve invalid runs honestly

An invalid post-plugin run may still be valuable as a control if the conditions are understood. Gunk Buster's invalid run and valid run were six minutes apart with the same commit, prompt, worktree, model, effort, harness, and host; the isolated difference was MCP tool exposure.

This supported a matched-pair observation:

| Metric | Tools absent | Tools present | Delta |
| --- | ---: | ---: | ---: |
| Wall clock | 122.4s | 108.6s | −11.3% |
| Reasoning output | 813 | 693 | −14.8% |
| Answer output | 5,782 | 4,766 | −17.6% |
| Shell commands | 18 | 15 | −16.7% |
| Uncached input | 58,144 | 57,432 | −1.2% |
| Total input | 317.7K | 408.7K | +28.6% |

The correct public interpretation was:

- automatic plugin activation was proven;
- the matched pair was directional, not statistical;
- reasoning, output, shell exploration, and wall time fell in this pair;
- cached and total input rose;
- answer quality did not regress on a prompt-derived checklist;
- no universal cost or speed claim was justified.

### Publish limitations as part of the evidence

Always disclose relevant limitations:

- sample size;
- stochastic agent paths;
- model and reasoning effort;
- cache behavior;
- repository drift;
- instrumentation changes;
- ordering and service-load effects;
- absent answer-quality rubric;
- excluded or interrupted runs;
- platform certification scope.

Credible proof is often asymmetric. Gunk Buster's repeated context-cleanup experiment showed improvements at medium effort and substantial regression at high effort. Publishing both prevented a false “always saves tokens” story.

### Use a reproducibility protocol for agent and LLM benchmarks

For stochastic model or agent evaluations, strengthen the harness beyond a single matched pair:

- predeclare the hypothesis, primary metrics, quality rubric, exclusions, and stopping rule;
- run same-condition repeats first to estimate the noise floor;
- randomize or interleave treatment order when service load, cache state, or warm-up effects may matter;
- pin the repository commit, prompt, model identifier, reasoning effort, tool configuration, and harness version;
- preserve raw traces, outputs, timestamps, environment details, and invalid runs;
- report distributions or uncertainty when there are enough repetitions, not only the best run or one percentage delta;
- separate functional success, answer quality, latency, token usage, and monetary cost instead of collapsing them into one score;
- rerun or explicitly expire claims when a hosted model, agent runtime, tool protocol, or provider behavior changes materially.

A 2025 large-scale study of 640 LLM-for-software-engineering papers found persistent reproducibility gaps in environment specification, versioning, documentation, model identification, and long-term artifact executability ([Siddiq et al., 2025](https://arxiv.org/abs/2512.00651)). The practical lesson for repository marketing is simple: if a benchmark is part of the product story, its reproducibility artifacts are part of the product surface.

### Benchmark presentation template

```markdown
## Proof, not promises

### Question
[The exact behavior or performance hypothesis.]

### Method
- fixed commit:
- fixed prompt:
- model and effort:
- conditions:
- repetitions:
- validity gates:
- quality rubric:

### Result
[Compact table with raw units and deltas.]

### What this supports
[Narrow claim.]

### What this does not support
[Explicit rejected generalizations.]

### Reproduce it
[Link to harness, raw data, saved outputs, and environment details.]
```

---

## 8. Build the supporting trust layer

The README is the front door; supporting files make the project inhabitable.

### Minimum launch documentation

| File | Purpose |
| --- | --- |
| `README.md` | Understand, trust, try, and navigate |
| `LICENSE` | Legal permission to use and contribute |
| `CONTRIBUTING.md` | Scope, setup, test, and PR expectations |
| `CODE_OF_CONDUCT.md` | Participation expectations |
| `SECURITY.md` | Private reporting path, disclosure process, and supported versions |
| `MAINTAINERS.md` or `GOVERNANCE.md` | Maintainer roles, authority, and escalation path when the project has multiple maintainers |
| `SUPPORT.md` or support section | Supported versions, support channels, and what maintainers do not promise |
| `docs/INSTALL.md` | Install, update, remove, and platform nuances |
| `docs/CLI.md` or equivalent | Commands, config, outputs, exit behavior |
| `docs/SAFETY.md` | Trust boundaries, mutations, recovery, caveats |
| `AGENTS.md` / repository AI instructions when relevant | Build, test, structure, and invariant context for coding agents |
| ADR index | Discoverable architectural decisions |
| Issue forms | Structured bug and feature intake |
| PR template | Change intent, impact, tests, and safety checklist |

GitHub's community profile checks for README, code of conduct, license, contribution guidelines, issue templates, and related community-health files. See [GitHub community profiles](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/about-community-profiles-for-public-repositories).

### Progressive disclosure

Use three documentation layers:

1. **README:** fastest correct path and decision-making information.
2. **Task guides:** installation, CLI, configuration, troubleshooting, safety.
3. **Maintainer evidence:** ADRs, specifications, benchmark raw data, certification records.

Do not force new users to read internal design history. Do not erase that history either.

### Define AI-assisted contribution expectations when they matter

A 2025 empirical study of more than 250,000 GitHub repositories found explicit project-level policies and disclosures around GenAI use, with recurring concerns about quality control, attribution, legal risk, and transparency ([Xiao et al., 2025](https://arxiv.org/abs/2507.10422)). If AI-assisted contributions are common in your ecosystem, state only the rules you can actually review and enforce. Examples include requiring contributors to run the normal test suite, review generated code for licensing/security issues, avoid including secrets or private data in external tools, and take responsibility for submitted changes regardless of how they were produced.

Do not create an AI policy merely to look current. Add one when it resolves a real contributor, legal, security, or review ambiguity.

### Repository metadata is part of marketing

Configure:

- a concise description that states category and outcome;
- homepage or documentation URL when useful;
- focused topics;
- social preview;
- private vulnerability reporting;
- license recognition;
- release feed;
- pinned repository placement on the maintainer profile.

GitHub topics improve discovery and should represent purpose, subject area, community, or language. GitHub permits up to 20 lowercase/hyphenated topics ([GitHub topics guidance](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/classifying-your-repository-with-topics)). Use fewer, stronger topics rather than filling the limit.

For Gunk Buster, the metadata focused on concepts such as `agent-context`, `ai-agents`, `coding-agents`, `repository-hygiene`, `mcp`, `codex`, `claude-code`, `local-first`, and `typescript`.

### Security is a launch feature

A public developer tool should provide a private vulnerability path. GitHub recommends `SECURITY.md` and offers private vulnerability reporting for public repositories ([GitHub repository best practices](https://docs.github.com/en/repositories/creating-and-managing-repositories/best-practices-for-repositories), [private vulnerability reporting](https://docs.github.com/en/enterprise-cloud@latest/code-security/how-tos/report-and-fix-vulnerabilities/configure-vulnerability-reporting/configure-for-a-repository)).

Security copy must describe real boundaries, not aspirational ones.

### Adopt a concrete supply-chain baseline

For security-sensitive or widely distributed tools, use the [OpenSSF Open Source Project Security Baseline](https://baseline.openssf.org/versions/2026-02-19) as a release-readiness checklist rather than inventing a private checklist from scratch. The February 2026 baseline includes controls for contribution guidance, build instructions, vulnerability disclosure, automated testing, release identification, dependency management, signed or hashed release artifacts, least-privilege CI, support windows, SBOMs at higher maturity, and human review requirements.

Do not turn an automated score into a trust claim. [OpenSSF Scorecard](https://openssf.org/projects/scorecard/) is useful for finding concrete repository risks, and the [OpenSSF Best Practices Badge](https://openssf.org/projects/best-practices-badge/) can document self-assessed process maturity, but neither proves that the software is vulnerability-free.

For release provenance maturity, use the current [SLSA v1.2 build track](https://slsa.dev/spec/v1.2/build-track-basics) as a vocabulary: Build L1 means provenance exists, Build L2 uses a hosted build platform, and Build L3 adds hardened-build requirements. An attestation by itself is not a SLSA level claim; the build system and provenance must satisfy the level's requirements.

### Harden the repository before promotion

For a public GitHub repository, review at least:

- branch and tag rulesets with required pull requests and status checks where appropriate ([GitHub rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets));
- explicit least-privilege `GITHUB_TOKEN` permissions in Actions workflows;
- full-length commit-SHA pinning for third-party Actions, or an organization policy that enforces it ([GitHub Actions secure-use reference](https://docs.github.com/en/actions/reference/security/secure-use));
- secret scanning and push protection where available ([GitHub security features](https://docs.github.com/en/code-security/getting-started/github-security-features));
- dependency review for pull requests that change manifests or lockfiles ([GitHub dependency review](https://docs.github.com/en/code-security/concepts/supply-chain-security/dependency-review));
- private vulnerability reporting and a response policy;
- release provenance and verification instructions for artifacts users execute.

These controls belong in launch readiness because a successful launch increases both legitimate adoption and attacker attention.

---

## 9. Prepare the package as a product

### Package metadata checklist

For npm, review:

- `name` and registry availability;
- `version` and semver intent;
- useful `description`;
- `keywords` aligned with repository topics;
- `homepage`;
- `bugs.url`;
- exact `repository.url`;
- author or maintainers;
- license;
- entry points and exports;
- executable `bin` paths;
- runtime `engines`;
- package-manager declaration;
- `files` allowlist;
- `publishConfig.access` for public scoped packages;
- build and prepublish behavior.

npm recommends a custom description for discoverability and uses the root package README on the npm page. That README only updates when a new version is published ([npm package metadata](https://docs.npmjs.com/creating-a-package-json-file/), [npm README guidance](https://docs.npmjs.com/about-package-readme-files/)).

### Inspect the tarball before publishing

Run:

```bash
npm pack --dry-run --json
```

Review every included file, total size, executables, README, license, and generated bundle. npm's `files` field is an allowlist; `package.json`, README, license, and bin files receive special handling ([npm package.json documentation](https://docs.npmjs.com/files/package.json/)).

Then test the actual tarball or packed directory in isolation:

1. create a temporary directory outside the repository;
2. install the package globally or locally from the tarball;
3. run `--version` and `--help`;
4. execute a representative workflow against a fixture repository;
5. verify no source-tree dependency was accidentally used;
6. confirm uninstall behavior.

Gunk Buster's launch gate verified a seven-file package and exercised the globally installed CLI against a real fixture before publication.

### Do not advertise an unpublished package

If the package does not exist in the registry or authentication is unavailable:

- keep the source-install path public;
- say that npm publication is pending;
- do not show `npm install -g package` as the supported path;
- do not create a matching GitHub release that implies registry availability.

This was the correct Gunk Buster decision when `npm whoami` returned `ENEEDAUTH` and the registry returned 404.

### Prefer trusted publishing over long-lived write tokens

As of August 2026, npm trusted publishing uses OIDC to issue short-lived workflow-specific credentials. It supports GitHub Actions, GitLab CI/CD, and CircleCI cloud-hosted runners. Current npm documentation requires npm CLI 11.5.1 or later and Node 22.14.0 or later. Each package can have one trusted publisher configuration at a time, and the trust can be restricted to `npm publish`, `npm stage publish`, or both ([npm trusted publishing](https://docs.npmjs.com/trusted-publishers/)).

For public packages from public repositories, trusted publishing automatically generates npm provenance when publishing from GitHub Actions or GitLab CI/CD. CircleCI trusted publishing currently does not generate npm provenance. For GitHub-based trusted publishing, `repository.url` must exactly match the repository ([npm provenance](https://docs.npmjs.com/generating-provenance-statements/)).

Once OIDC publishing works, npm recommends restricting traditional publishing access. Prefer **Require two-factor authentication and disallow tokens**, then revoke unnecessary granular write tokens. Legacy access tokens were removed in November 2025; only granular access tokens remain. As of August 2026, bypass-2FA tokens also cannot perform account-identity or account-governance actions ([npm access tokens](https://docs.npmjs.com/about-access-tokens/), [npm 2FA requirements](https://docs.npmjs.com/requiring-2fa-for-package-publishing-and-settings-modification/)).

For a first manual publication, require:

- authenticated npm account;
- account-level 2FA;
- clean, reviewed commit;
- passing test/build/typecheck;
- inspected package contents;
- isolated installation success;
- correct access setting;
- no secrets in the tarball.

### Use staged publishing for a higher-assurance npm release

npm introduced staged publishing in 2026. `npm stage publish` uploads a package version into a non-public staging area, where a maintainer can inspect or download the exact staged tarball and then approve it with 2FA. Current requirements are npm CLI 11.15.0 or later and Node 22.14.0 or later ([npm staged publishing](https://docs.npmjs.com/staged-publishing/)).

For security-sensitive packages, the strongest practical configuration is:

1. configure trusted publishing with **stage-only** permission;
2. configure the package to require 2FA and disallow traditional tokens;
3. let CI run tests, build, inspect the package, and execute `npm stage publish`;
4. have a maintainer inspect the staged package using `npm stage view` and, when useful, `npm stage download`;
5. approve with `npm stage approve <stage-id>` and 2FA;
6. independently install the live registry version before announcing it.

This inserts human proof-of-presence after automation has produced the candidate artifact, without restoring a long-lived publishing secret.

### Release ordering

Use this order:

1. Merge the launch changes and verify the exact release commit.
2. Confirm rulesets, CI permissions, and publishing configuration are in the intended state.
3. Build, test, typecheck, and run security/release checks from the release commit.
4. Inspect `npm pack --dry-run --json` and test the packed artifact outside the source tree.
5. Publish through trusted publishing, or stage it with `npm stage publish` and approve the inspected candidate with 2FA.
6. Install the live registry version in a clean environment.
7. Confirm version, help, representative behavior, and provenance/registry metadata.
8. Create a draft GitHub Release for the matching tag and attach any release assets.
9. Publish the GitHub Release only after the registry artifact is verified.
10. Verify the published release and assets, then publish announcements using the verified registry and release URLs.

GitHub Releases are based on tags and provide a durable page for deployable iterations, generated source archives, release notes, and optional assets ([GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases)). GitHub now also supports **immutable releases**: after publication, the associated tag is locked and release assets cannot be modified or deleted, and GitHub generates a signed release attestation. GitHub recommends creating the release as a draft, attaching all assets, then publishing it ([GitHub immutable releases](https://docs.github.com/en/code-security/concepts/supply-chain-security/immutable-releases)).

For uploaded release assets, GitHub also exposes SHA-256 digests in the UI, API, and CLI. For binaries and container images built in GitHub Actions, consider first-party artifact attestations and publish verification instructions such as `gh attestation verify` for consumers ([GitHub artifact attestations](https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/use-artifact-attestations), [release-asset digests](https://github.blog/changelog/2025-06-03-releases-now-expose-digests-for-release-assets/)).

Attestations prove provenance and integrity relationships; they do **not** prove that an artifact is secure. Treat verification as an additional trust signal, not a substitute for testing, review, or vulnerability management.

Never let the release page get ahead of the installable artifact.

---

## 10. Launch marketing that respects developer communities

### Create a launch kit

Prepare before publishing:

- one-sentence position;
- short and long project descriptions;
- square logo;
- social card;
- 15-second visual or static demo;
- one representative before/after;
- one proof table;
- installation command;
- limitations paragraph;
- release notes;
- maintainer story: why this problem mattered;
- responses to likely objections;
- links for issues, security, docs, and contribution.

### Message hierarchy

Every launch post should contain:

1. recognizable pain;
2. memorable product idea;
3. concrete demonstration;
4. proof or trust boundary;
5. shortest path to try it;
6. a specific request for feedback.

Example structure:

```text
Coding agents read stale repository context and act on it.

[PROJECT] finds that [MEMORABLE ENEMY] before the agent does.

[ONE-SENTENCE DEMO OR RESULT]

It is [TRUST BOUNDARIES]. The current benchmark shows [NARROW RESULT],
with [IMPORTANT LIMITATION].

Try it: [COMMAND OR URL]

I especially want feedback from [TARGET USERS] about [SPECIFIC QUESTION].
```

### Go where the problem is already discussed

The Open Source Guides recommends targeted participation rather than indiscriminate promotion. Find communities where users are already experiencing the problem, help first, ask for focused feedback, and treat launch as an iterative process rather than one announcement ([Finding Users for Your Project](https://opensource.guide/finding-users/)).

Potential channels for developer tools:

- GitHub Discussions and adjacent project issues where relevant;
- Hacker News “Show HN” when the project is ready for technical scrutiny;
- focused subreddits with community-appropriate disclosure;
- Discord or Slack communities for supported tools;
- maintainer networks and ecosystem newsletters;
- short demo posts on LinkedIn, X, or Mastodon;
- package registry and plugin marketplace discovery;
- documentation or blog posts teaching the underlying problem.

Do not spam every channel with identical copy. Adapt the demonstration and question to the community.

### Market through useful artifacts

The strongest recurring strategy among the reference repositories is not generic promotion. It is publishing something useful:

- a reproducible benchmark;
- a corrected benchmark after criticism;
- a before/after case study;
- a clear methodology;
- a migration guide;
- a safety analysis;
- an integration recipe;
- an honest compatibility matrix.

Useful evidence earns attention longer than slogans.

### Track a funnel and community health, not one popularity number

Track signals by stage:

- **Awareness:** repository traffic when available, qualified external mentions, stars and forks as directional awareness only;
- **Activation:** README-to-install conversion when measurable, package/plugin installs, first successful run, and first-success failures;
- **Adoption:** repeat usage signals that respect the project's privacy model, downstream integrations, dependents, and upgrade uptake;
- **Community:** new contributors, repeat contributors, pull-request participation, issue themes, and time to first response;
- **Reliability:** support burden per new user, install failure rate, regression themes, and security-report handling;
- **Evidence:** benchmark reproductions, external case studies, independent comparisons, and corrected claims.

Use [CHAOSS](https://www.chaoss.community/kbtopic/all-metrics/) definitions when you need repeatable community metrics. Useful starting points include [Time to First Response](https://www.chaoss.community/kb/metric-time-to-first-response/), [New Contributors](https://chaoss.community/kb/metric-new-contributors/), and [Release Frequency](https://www.chaoss.community/kb/metric-release-frequency/).

Do not optimize the project for stars. A 2026 longitudinal preprint on 15 open-source multi-agent frameworks found that star volume could diverge sharply from contributor density and retention, reinforcing the need to separate visibility from durable ecosystem participation ([Zhang et al., 2026](https://arxiv.org/abs/2607.02453)). Treat that result as evidence from one fast-moving domain, not a universal conversion ratio.

Update the README, onboarding, and support docs when actual user questions reveal repeated friction. Marketing is a maintained interface.

---

## 11. The reusable execution SOP

### Stage 1 — Discover

- [ ] Inspect implementation, docs, manifests, tests, releases, and registry state.
- [ ] Identify stale authority and contradictory claims.
- [ ] List supported, verified, certified, experimental, and unavailable surfaces.
- [ ] Record product non-goals and safety boundaries.
- [ ] Create a claim ledger.

### Stage 2 — Research

- [ ] Identify the target user's job and failure mode.
- [ ] Review adjacent repositories through current primary sources.
- [ ] Record patterns, not just visual preferences.
- [ ] Build a private differentiation matrix.
- [ ] Check current platform, registry, security-baseline, and release-integrity documentation.
- [ ] Audit current AI-agent instruction formats and support if the repository targets coding agents.

### Stage 3 — Position

- [ ] Write the precise positioning sentence.
- [ ] Name the enemy or failure mode.
- [ ] Write the memorable short promise.
- [ ] Define one primary adoption path.
- [ ] Choose the strongest truthful proof.

### Stage 4 — Brand

- [ ] Translate the product mechanism into a visual metaphor.
- [ ] Write an originality-safe 1:1 logo brief.
- [ ] Test the mark at avatar size.
- [ ] Establish light/dark palette and typography.
- [ ] Produce mark, hero, demo, and social-card assets.
- [ ] Add useful alt text.
- [ ] Inspect every final asset visually and mechanically.

### Stage 5 — Write

- [ ] Hero: identity, promise, category, truthful badges.
- [ ] Problem: recognizable pain and named enemy.
- [ ] Demo: real, representative, and bounded.
- [ ] Quick start: tested primary path first.
- [ ] Proof: evidence plus limitations.
- [ ] Workflow: smallest useful mental model.
- [ ] Safety: does/does-not and non-goals.
- [ ] Compatibility: precise status language.
- [ ] Architecture: overview only.
- [ ] Docs, contributing, security, license, CTA.

### Stage 6 — Complete the repository surface

- [ ] Installation guide.
- [ ] CLI/API/configuration reference.
- [ ] Safety model.
- [ ] ADR or design index.
- [ ] License.
- [ ] Contributing guide.
- [ ] Code of conduct.
- [ ] Security policy and private reporting.
- [ ] Maintainer/governance and support policy when the project scope warrants them.
- [ ] Agent instructions are current, scoped, and non-contradictory when applicable.
- [ ] Issue forms and PR template.
- [ ] Description, topics, homepage, and social preview.

### Stage 7 — Prove

- [ ] Choose functional or performance hypothesis explicitly.
- [ ] Estimate total cost before agent runs.
- [ ] Reuse existing evidence where possible.
- [ ] Add pre-model validity gates.
- [ ] Record exact prompt, commit, environment, and tool trace.
- [ ] Score answer quality against a predeclared checklist.
- [ ] Preserve invalid and interrupted runs transparently.
- [ ] State what the result does and does not support.

### Stage 8 — Package

- [ ] Verify package name and version.
- [ ] Complete metadata and repository URL.
- [ ] Build and run the complete test suite.
- [ ] Inspect `npm pack --dry-run --json`.
- [ ] Install the packed artifact in isolation.
- [ ] Run executable smoke tests.
- [ ] Verify README rendering strategy on the registry.
- [ ] Confirm 2FA and trusted publishing configuration.
- [ ] Prefer staged publishing for higher-assurance npm releases.
- [ ] Confirm provenance behavior and inspect the exact staged/published artifact.

### Stage 9 — Review

- [ ] Product/spec review: did the implementation satisfy the plan?
- [ ] Standards review: are claims accurate and boundaries structurally true?
- [ ] Supply-chain review: rulesets, workflow permissions, action pinning, dependency review, secret protection, and release integrity.
- [ ] Accessibility review: alt text, contrast, text-as-image fallbacks.
- [ ] Link check.
- [ ] Asset dimension and XML validation.
- [ ] Diff check and clean worktree.
- [ ] Resolve every release-blocking finding before push.

### Stage 10 — Release and launch

- [ ] Merge reviewed changes.
- [ ] Publish and smoke-test the registry artifact.
- [ ] Tag the exact release commit.
- [ ] Create the GitHub Release as a draft and attach final assets.
- [ ] Publish an immutable release when appropriate and verify release/asset integrity.
- [ ] Upload social preview in repository settings.
- [ ] Publish channel-specific launch posts.
- [ ] Ask a specific target audience for specific feedback.
- [ ] Watch first-user failures and update docs quickly.

---

## 12. Reusable worksheets

### Positioning worksheet

```text
Project:
Primary audience:
Situation/job:
Existing failure or cost:
Category:
Distinct mechanism:
Important non-goals:
Primary adoption path:
Strongest proof:

Precise position:
[Project] is a [category] for [audience] that [outcome] by [mechanism],
without [rejected trade-off].

Memorable promise:

Named enemy/failure mode:
```

### Claim ledger

```markdown
| Claim | Evidence | Confidence | Qualification | README wording | Deep link |
| --- | --- | --- | --- | --- | --- |
```

### Reference-repository teardown

```markdown
## Repository

- Audience:
- One-line promise:
- Named enemy:
- First proof:
- First install action:
- Brand device:
- README structure:
- Benchmark quality:
- Trust boundaries:
- Community layer:
- What to adapt:
- What not to copy:
```

### README skeleton

```markdown
[Logo / theme-aware hero]

[One-line promise]
[One or two lines explaining category and audience]
[Truthful badges]
[Compact section navigation]

## Why this exists
[Recognizable problem and named failure mode]

## See it
[Representative demonstration and explanation]

## Quick start
[Primary supported install and first successful action]

## Proof, not promises
[Strongest functional proof, bounded metrics, limitations, raw evidence]

## How it works
[Workflow]

## Safety and non-goals
[Does/does-not table]

## Supported surfaces
[Precise status matrix]

## Architecture
[Top-level model and deep links]

## Documentation
[Task-oriented map]

## Contributing
[Focused invitation]

## Security
[Private reporting route]

## License

[One in-character CTA]
```

### Release gate

```markdown
- [ ] Public claims match executable behavior
- [ ] No stale authoritative instructions
- [ ] Full tests/typecheck/build pass
- [ ] Package contents inspected
- [ ] Packed install works outside source tree
- [ ] Account 2FA and publishing authorization confirmed
- [ ] Trusted publisher configured; unnecessary write tokens removed
- [ ] Staged publishing used when the release risk warrants proof-of-presence
- [ ] Version available and correct
- [ ] README install commands tested verbatim
- [ ] Security policy and private reporting ready
- [ ] Rulesets, workflow permissions, and third-party Action pinning reviewed
- [ ] Secret scanning/dependency review configuration checked where available
- [ ] Description and topics applied
- [ ] Social preview uploaded
- [ ] Release notes prepared
- [ ] Package published and independently installed
- [ ] Provenance/attestations/checksums verified where applicable
- [ ] GitHub tag/release matches package version
- [ ] Immutable release enabled when appropriate
- [ ] Announcement URLs verified
```

---

## 13. Failure patterns to avoid

### Marketing a planned product instead of the current tree

Symptom: README and `AGENTS.md` say “pre-code” while binaries and integrations exist.

Fix: audit truth first and update authoritative context before launch copy.

### Leading with an architecture inventory

Symptom: visitors learn directory names before understanding why the tool matters.

Fix: value → demonstration → install → proof → workflow → architecture.

### Treating personality as a substitute for precision

Symptom: memorable mascot and slogans, but no correct install or trust boundary.

Fix: use personality to increase recall; use evidence to earn trust.

### Copying the visual grammar of a famous brand

Symptom: derivative character, composition, or wordmark.

Fix: borrow genre energy, not protected expression. Connect the final metaphor to the product's mechanism.

### Embedding raster assets inside SVG without portability testing

Symptom: blank image in some renderers.

Fix: use direct Markdown/HTML images, self-contained SVG, or flattened PNG output.

### Claiming read-only behavior from intent or annotations

Symptom: metadata says read-only while a nested call executes shell commands.

Fix: trace every code path, enforce the boundary, and test a mutation attempt.

### Equating a successful process exit with valid benchmark exposure

Symptom: agent produces a plausible result even though the plugin server never started.

Fix: verify environment prerequisites and record mechanical tool-call events.

### Estimating agent cost from final context occupancy

Symptom: a supposedly 65K run bills several hundred thousand cumulative input tokens.

Fix: estimate from cumulative telemetry and define an abort budget.

### Repeating expensive experiments to manufacture confidence

Symptom: quota is exhausted proving a performance claim the product does not need.

Fix: separate functional acceptance from statistical performance; reuse saved artifacts and zero-cost scoring.

### Hiding negative or invalid evidence

Symptom: only favorable runs appear in the README.

Fix: preserve exclusions and explain why. Negative results often define the honest claim boundary.

### Advertising npm before npm exists

Symptom: users copy a polished install command and receive 404.

Fix: advertise source install until registry publication and independent smoke verification succeed.

### Creating the GitHub Release before the package is usable

Symptom: release page implies a complete launch while the package cannot be installed.

Fix: publish → install from registry → verify → tag/release → announce.

### Assuming a committed social card is active

Symptom: asset exists in Git but shared links still show the owner avatar or old image.

Fix: upload the image separately through repository settings.

### Keeping long-lived npm write tokens after OIDC works

Symptom: trusted publishing is configured, but old CI tokens with publish access remain active.

Fix: verify OIDC publishing first, then revoke unnecessary write tokens and configure the package to disallow traditional token publishing where practical.

### Publishing mutable release assets that users execute

Symptom: binaries can be replaced after a release announcement without changing the release page or tag.

Fix: use GitHub immutable releases for final artifacts when appropriate, attach assets before publication, and publish verification instructions.

### Treating provenance as a vulnerability scan

Symptom: a provenance badge is presented as proof that the software is safe.

Fix: state the narrower claim. Provenance shows where and how an artifact was built; testing, review, SAST/SCA, threat analysis, and vulnerability response address different risks.

### Letting AI instruction files drift apart

Symptom: `AGENTS.md`, Copilot instructions, and tool-specific files provide different build commands or security rules.

Fix: keep a canonical source, minimize duplication, and review all agent-facing instructions as part of release readiness.

---

## 14. Gunk Buster case-study outcome

The execution produced:

- a plugin-first README centered on “hallucination bait”;
- an original digital-zombie mascot tied to stale context;
- light/dark wordmarks, coherent badges, terminal demo, and 1280×640 social card;
- a real fixture-derived demonstration;
- activation proof and bounded benchmark observations;
- clear safety and non-goal tables;
- installation, CLI, safety, ADR, and skill documentation;
- license, contribution guide, code of conduct, security policy, issue forms, and PR template;
- improved package metadata and a verified package dry run;
- an isolated global-install smoke test;
- GitHub description, focused topics, and private vulnerability reporting;
- independent spec and standards reviews;
- a draft launch PR rather than an unsafe direct push.

Verification included:

- full test suite passing after the final behavioral safety fix;
- typecheck and build;
- focused MCP regression tests;
- README link validation;
- SVG XML and raster-dimension checks;
- package-content inspection;
- isolated installed-package behavior;
- visual inspection of every branded asset;
- clean diff and worktree checks.

The launch correctly remained gated on:

- npm maintainer authentication and publication;
- independent installation of the registry version;
- creation of the matching GitHub release after npm success;
- manual upload of the social-preview image in GitHub settings.

This is the desired end state of a responsible launch process: highly polished, but unwilling to pretend an unfinished external step is complete.

---

## 15. Primary references

### GitHub

- [About repository README files](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes)
- [Basic writing and formatting syntax](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)
- [Community profiles for public repositories](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/about-community-profiles-for-public-repositories)
- [Classifying repositories with topics](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/classifying-your-repository-with-topics)
- [Customizing the social media preview](https://docs.github.com/en/enterprise-cloud@latest/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/customizing-your-repositorys-social-media-preview)
- [Repository best practices](https://docs.github.com/en/repositories/creating-and-managing-repositories/best-practices-for-repositories)
- [Private vulnerability reporting](https://docs.github.com/en/enterprise-cloud@latest/code-security/how-tos/report-and-fix-vulnerabilities/configure-vulnerability-reporting/configure-for-a-repository)
- [About GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases)
- [Immutable releases](https://docs.github.com/en/code-security/concepts/supply-chain-security/immutable-releases)
- [Artifact attestations](https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/use-artifact-attestations)
- [Rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
- [GitHub Actions secure-use reference](https://docs.github.com/en/actions/reference/security/secure-use)
- [Dependency review](https://docs.github.com/en/code-security/concepts/supply-chain-security/dependency-review)
- [GitHub security features](https://docs.github.com/en/code-security/getting-started/github-security-features)
- [Repository custom instructions for Copilot](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions-in-your-ide/add-repository-instructions-in-your-ide)
- [Custom-instructions support matrix](https://docs.github.com/en/copilot/reference/custom-instructions-support)
- [Repository limits](https://docs.github.com/en/repositories/creating-and-managing-repositories/repository-limits)

### npm

- [Creating a package.json](https://docs.npmjs.com/creating-a-package-json-file/)
- [package.json reference](https://docs.npmjs.com/files/package.json/)
- [Package README files](https://docs.npmjs.com/about-package-readme-files/)
- [Creating and publishing public packages](https://docs.npmjs.com/creating-and-publishing-scoped-public-packages/)
- [Trusted publishing](https://docs.npmjs.com/trusted-publishers/)
- [Staged publishing](https://docs.npmjs.com/staged-publishing/)
- [Provenance statements](https://docs.npmjs.com/generating-provenance-statements/)
- [Requiring 2FA for publishing and settings](https://docs.npmjs.com/requiring-2fa-for-package-publishing-and-settings-modification/)
- [About access tokens](https://docs.npmjs.com/about-access-tokens/)

### Open-source growth and community health

- [Finding Users for Your Project](https://opensource.guide/finding-users/)
- [CHAOSS metrics](https://www.chaoss.community/kbtopic/all-metrics/)
- [CHAOSS Time to First Response](https://www.chaoss.community/kb/metric-time-to-first-response/)
- [CHAOSS New Contributors](https://chaoss.community/kb/metric-new-contributors/)
- [CHAOSS Release Frequency](https://www.chaoss.community/kb/metric-release-frequency/)

### Supply-chain and project-security frameworks

- [OpenSSF Open Source Project Security Baseline, 2026-02-19](https://baseline.openssf.org/versions/2026-02-19)
- [OpenSSF Scorecard](https://openssf.org/projects/scorecard/)
- [OpenSSF Best Practices Badge](https://openssf.org/projects/best-practices-badge/)
- [SLSA v1.2 build track](https://slsa.dev/spec/v1.2/build-track-basics)
- [SLSA provenance v1](https://slsa.dev/provenance/v1)

### Research

- [Imani et al. (2024), Does Documentation Matter?](https://arxiv.org/abs/2403.03819)
- [Gaughan et al. (2025), The Introduction of README and CONTRIBUTING Files in Open Source Software Development](https://arxiv.org/abs/2502.18440)
- [Siddiq et al. (2025), Large Language Models for Software Engineering: A Reproducibility Crisis](https://arxiv.org/abs/2512.00651)
- [Feng et al. (2026), Addressing OSS Community Managers' Challenges in Contributor Retention](https://arxiv.org/abs/2602.11447)
- [Zhang et al. (2026), Adoption and Ecosystem Health: A Longitudinal Analysis of Open-Source Multi-Agent Frameworks](https://arxiv.org/abs/2607.02453)
- [Xiao et al. (2025), Self-Admitted GenAI Usage in Open-Source Software](https://arxiv.org/abs/2507.10422)

### Reference repositories

- [obra/superpowers](https://github.com/obra/superpowers)
- [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail)
- [gustavo-meilus/superpipelines](https://github.com/gustavo-meilus/superpipelines)
- [gustavo-meilus/gunk-buster](https://github.com/gustavo-meilus/gunk-buster)

---

## Final principle

> Make the repository easy to recognize, easy to try, hard to misunderstand, and impossible to trust for the wrong reasons.

Brand gets attention. README structure converts attention into understanding. Proof converts understanding into trust. Packaging converts trust into adoption. Honest limitations keep that trust after launch.

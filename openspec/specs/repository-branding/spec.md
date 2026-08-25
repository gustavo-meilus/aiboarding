# repository-branding Specification

## Purpose

Defines the public repository experience that makes AIBoarding recognizable, truthful, accessible, easy to try, and consistent across its documented distribution surfaces.

## Requirements

### Requirement: Public claims follow repository truth
Every public claim SHALL agree with executable behavior, shipped manifests, the current published release, and retained verification evidence in that order. Version, support, safety, installation, and performance claims MUST be qualified at the narrowest level the evidence supports.

#### Scenario: Public versions are compared
- **WHEN** a visitor reads the README, plugin manifests, changelog, and current release references
- **THEN** those surfaces identify the same current release or avoid a hard-coded version that can become stale

#### Scenario: Evidence-backed claim is presented
- **WHEN** the README states a functional or benchmark result
- **THEN** the claim links to the relevant method or evidence and states its material limitations beside the claim

#### Scenario: Capability is not currently available
- **WHEN** an install path, runtime integration, certification, or external repository setting has not been verified
- **THEN** the public surface MUST describe it as pending, portable, experimental, degraded, or unavailable rather than supported without qualification

### Requirement: Positioning is recognizable and consistent
The repository SHALL present one precise position for maintainers who use AI coding agents: AIBoarding creates and maintains canonical repository onboarding so agents avoid repeated rediscovery and onboarding drift without duplicating instruction sources or broadly rewriting unchanged guidance. The README, plugin listings, repository metadata, and calls to action MUST preserve that audience, outcome, mechanism, and boundary while adapting length to each surface.

#### Scenario: Visitor compares public descriptions
- **WHEN** a visitor reads the README hero, Claude marketplace listing, Codex plugin listing, and repository description
- **THEN** each description conveys the same audience, current-onboarding outcome, and lifecycle mechanism without contradictory category or capability claims

#### Scenario: Short promise is used
- **WHEN** a compact surface cannot carry the precise positioning sentence
- **THEN** it uses the boarding-pass metaphor or the existing “keeps AGENTS.md alive” promise without replacing factual product explanation

### Requirement: Visual identity is complete and portable
AIBoarding SHALL use an original visual system derived from the existing onboarding-document, route, and verification mark. The asset family MUST include a square master mark, an optimized small icon, light and dark README treatments, a representative product demonstration, and a 1280x640 social preview while preserving a consistent palette and silhouette.

#### Scenario: Asset renders without repository-relative embedding
- **WHEN** an SVG or flattened social asset is rendered outside the source checkout
- **THEN** it renders completely without external fonts, sibling raster references, scripts, network resources, or missing linked content

#### Scenario: Asset is viewed across themes and sizes
- **WHEN** the mark and README treatment are inspected on light and dark backgrounds and the mark is reduced to avatar size
- **THEN** the identity remains legible, recognizable, and sufficiently contrasted without details collapsing

#### Scenario: Informative image is embedded
- **WHEN** the README displays a hero, demonstration, or other informative brand asset
- **THEN** the surrounding markup supplies useful alternative text or an equivalent text explanation

#### Scenario: Social preview is prepared
- **WHEN** the committed social-preview file is inspected
- **THEN** it is a standalone 1280x640 PNG under 1 MB with a solid background and the repository records that GitHub activation is a separate administrator action

### Requirement: README follows the adoption journey
The README SHALL lead a first-time visitor through value, recognizable problem, representative behavior, primary supported installation, evidence and limitations, workflow, safety and non-goals, supported surfaces, architecture, documentation, contribution, security, and license in that order of priority. The first successful action MUST appear before the deep architecture and repository inventory.

#### Scenario: First-time visitor scans the top of the README
- **WHEN** a maintainer opens the repository without prior AIBoarding knowledge
- **THEN** the hero identifies the product, intended user, memorable outcome, truthful status, and shortest supported install path before internal architecture details

#### Scenario: Visitor inspects the demonstration
- **WHEN** the README shows AIBoarding behavior
- **THEN** the example is derived from real repository fixtures or executable output and explains both what it proves and what it does not prove

#### Scenario: Visitor evaluates safety and compatibility
- **WHEN** the visitor reaches trust information
- **THEN** the README distinguishes implemented, automated, live-verified, portable, degraded, and unavailable surfaces and states relevant does/does-not boundaries

### Requirement: Distribution and trust surfaces form one front door
Plugin descriptions, manifest asset references, repository metadata guidance, contribution guidance, conduct expectations, issue intake, pull-request guidance, security reporting, license navigation, and README support links SHALL agree with the repository's current scope. The change MUST NOT imply that administrator-only metadata or social-preview activation occurred merely because files were committed.

#### Scenario: User enters through a plugin listing
- **WHEN** a user discovers AIBoarding through Claude or Codex
- **THEN** the listing uses the shared positioning, resolves its referenced brand assets from the plugin root, and links back to the canonical repository

#### Scenario: User wants help or to contribute
- **WHEN** a visitor looks for bug reporting, contribution expectations, participation rules, vulnerability reporting, or license terms
- **THEN** each route is discoverable from the README and directs the visitor to a focused repository-owned surface

#### Scenario: Maintainer prepares repository metadata
- **WHEN** repository files are ready but description, topics, homepage, or social preview require GitHub administration
- **THEN** the maintainer receives the exact intended values and manual steps, and completion remains unchecked until the live repository is verified

### Requirement: Branding regressions are checked mechanically and visually
The repository SHALL retain a runnable check that detects missing or malformed required assets, incorrect dimensions, broken local README references, invalid manifest asset paths, and stale cross-surface version or positioning markers. Final acceptance MUST also include visual inspection because mechanical validation cannot establish composition, contrast, or small-size recognition.

#### Scenario: Required public surface drifts
- **WHEN** a required asset is removed, a local link breaks, a manifest references a missing file, or a public version marker diverges from the manifest release
- **THEN** the deterministic branding check fails with the affected surface identified

#### Scenario: Mechanical checks pass
- **WHEN** all deterministic branding and repository tests pass
- **THEN** the reviewer still inspects every final raster and vector asset at intended and small sizes before accepting the change

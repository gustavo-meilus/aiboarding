# Design Spec: `create-onboarding` Skill

## Overview
The `create-onboarding` skill is part of the `onboard-ai` project. It automates the generation of a comprehensive `ONBOARDING.md` document for new or existing repositories. It treats an AI like a fresh software engineer, guiding it through a rapid onboarding process to instantly understand project scope, business logic, and architectural patterns.

## Trigger & Initialization
* **Explicit Invocation:** The user can trigger the skill manually (e.g., "Run create-onboarding").
* **Implicit Fallback:** If the `sync-onboarding` skill is executed and detects that no `ONBOARDING.md` exists in the workspace, it automatically triggers this skill.

## Phase 1: Background Crawl & Initial Grilling (Discover & Define)
When triggered, the skill splits into two parallel tracks:

### Track A: Agent-Driven Discovery
The agent immediately uses its available file-reading and directory-listing tools in the background to scan:
* `package.json` or equivalent dependency files
* Project directory structure
* Existing READMEs or documentation
* Goal: Automatically extract the tech stack, build steps, and standard engineering basics without bothering the user.

### Track B: The Grilling Interrogation
Simultaneously, the agent initiates a relentless `grill-me` style interrogation with the user.
* **Opening:** The agent starts with a direct prompt: *"I'm analyzing your codebase's structure in the background to grab the tech stack. While I do that, let's do a grilling session: What is the core business problem this project solves?"*
* **Execution:** Based on the user's initial answer, the AI walks down the conceptual tree, challenging statements and asking clarifying questions one-by-one.
* **Brain-dump Incentivization:** Every question is designed to incentivize a targeted brain-dump from the user on that specific micro-topic.

## Phase 2: Architectural & AI Context (Design)
As the grilling session progresses, the AI explicitly steers the conversation toward the Design phase:
* **Targeting AI Context:** The agent extracts architectural constraints and AI-specific guardrails.
* **Example Prompt:** *"You mentioned a custom Auth provider. What are the specific architectural 'gotchas' or AI failure modes related to this Auth setup?"*
* The agent ensures it captures known AI failure modes to prevent future sub-agents from making the same mistakes.

## Phase 3: Reconciliation & Gap Analysis (Deliver)
* **Hard Gate:** This phase *only* begins when **both** Track A (the automated background crawl) and Track B (the primary grilling session) are fully completed.
* **Cross-Examination:** The agent reviews its technical findings from Track A against the user's conceptual responses from Track B.
* **Targeted Gap Grilling:** The agent initiates a short, final grilling session specifically focused on discrepancies. It asks the user to clarify any ambiguity or missing links between the automated findings and the brain-dumped context.
* **Example Prompt:** *"The background crawl found a Postgres connection string, but you didn't mention a database in your architecture brain-dump. How does Postgres fit into the core domain logic, and are there any AI constraints here?"*

## Phase 4: Synthesis & Generation (Deliver)
* **Completion:** This phase triggers when the reconciliation grilling session reaches a natural conclusion.
* **Synthesis:** The agent combines the verified automated findings (Track A) with the extracted and reconciled domain knowledge (Track B).
* **Output:** It drafts a highly-structured `ONBOARDING.md` document containing:
  1. Standard Engineering Basics
  2. Domain & Business Logic
  3. AI-Specific Context
* **Verification:** The agent presents the drafted document to the user for final approval before writing it to the root of the repository.

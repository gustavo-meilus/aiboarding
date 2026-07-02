# AGENTS.md

## Project Purpose
Invoicing for freelancers. CANARY-AGENTS-BODY-9C2E

## Stack and Runtime
Node app.

## Build, Test, Run
Build: `npm run build`. Test: `npm test`.

## Architecture Map
Single package; `src/` is the app, `test/` mirrors it.

## Domain Model
Invoice, Client, Payment.

## Agent Guardrails
Auth provider is custom; do not assume NextAuth.

## Known Failure Modes
Agents assume Prisma; the ORM is hand-rolled.

## Verification Before Completion
Run `npm test` before claiming done.

## Escalation — Ask the User When
Anything touching billing math.

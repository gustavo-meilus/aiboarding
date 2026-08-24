# Example Service

This service coordinates customer requests across several internal systems. The
architecture has a gateway, a worker, and a reporting store. Routine status
notes may be shortened when they remain clear.

## Agent Guardrails
Never bypass authorization checks. Agents MUST NOT deploy without approval.
Only an authorized release manager may approve production deployment.

## Escalation - Ask the User When
Ask the user before changing public lifecycle semantics. Stop when a security
boundary is unclear.

## Release procedure
Before dropping the migration column, create a backup, verify it, then obtain
approval. Do not delete data unless the approved migration plan requires it.

## Security note
Secrets MUST remain outside instruction files; never print them in logs.

## Architecture
The gateway receives requests, workers process them, and reporting reads stored
results. This describes the system; it does not impose a safety constraint.

## Domain
Requests become jobs, then reports. This routine vocabulary is descriptive.

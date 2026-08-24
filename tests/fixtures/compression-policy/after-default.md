# Example Service

Gateway, worker, reporting store. Routine status notes may be shortened.

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
Gateway receives requests; workers process them; reporting reads results.

## Domain
Requests become jobs, then reports.

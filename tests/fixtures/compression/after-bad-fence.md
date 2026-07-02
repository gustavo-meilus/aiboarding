# AGENTS.md

## Build, Test, Run
Build from repo root: `npm run build --workspaces`. Then full checks:

```bash
npm test --coverage && npm run lint
```

Dev server: `npm run dev` → https://localhost:3000/dashboard. Entry point
src/server/index.ts; config read from config/default.json.

## Agent Guardrails
Never assume the ORM is Prisma. Data layer is hand-rolled in src/db/queries.ts.

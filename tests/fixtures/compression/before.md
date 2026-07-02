# AGENTS.md

## Build, Test, Run
In order to build the project, you should first make sure that you run the
command `npm run build --workspaces` from the repository root directory. After
that has completed successfully, it is generally recommended that you run the
full test suite by executing the following commands:

```bash
npm test -- --coverage
npm run lint
```

Please also note that the development server can be started with `npm run dev`
and it will then be available at https://localhost:3000/dashboard for you to
inspect. The main entry point of the application lives in src/server/index.ts,
and configuration is read from config/default.json.

## Agent Guardrails
It is very important that you never assume the ORM is Prisma, because the data
layer is completely hand-rolled and lives inside src/db/queries.ts.

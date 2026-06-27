# Quality Checks

Run `mix check` or `mix precommit` from the project root. Install backend and frontend dependencies first and start PostgreSQL. GitHub Actions runs the same suite against PostgreSQL 18.

ExCheck runs every check on each invocation; automatic retry-only runs are disabled. The dependency cleanup check is read-only. Use `mix check --only credo` to run one tool while fixing a finding.

## Backend

- **Boundary** checks module dependencies during compilation. `TemplateAppWeb` can use the domain's exported API; domain code cannot call web code. `TemplateApp.Application` is a separate startup boundary that can call both. Test case helpers are separate boundaries with outbound checks disabled so tests can exercise internals without widening the production API.
- **Credo** runs in strict mode, with **ExSlop**'s recommended checks and selected **Jump Credo Checks** for Elixir/Phoenix mistakes. `.credo.exs` lists the enabled checks.
- **ExcellentMigrations** checks every migration through Credo. The initial table-creation migrations contain reasoned safety annotations for indexes, references, constraints, and the `citext` extension. New migrations receive no automatic exemption.
- **ExDNA** checks duplication in `lib`. `.ex_dna.exs` requires three occurrences, matching the project's Rule of Three. It uses the CLI because version 1.5.4 does not ship the compiler task documented upstream.
- **MixAudit** checks the lockfile against known vulnerabilities. Hex's audit also checks retired dependencies. Both need network access; no vulnerability exceptions are configured.
- **MixUnused** runs during dev/test compilation and reports advisory hints. Its compiler traces do not include test-file calls, and default-argument functions and dynamic dispatch can produce false positives. `mix.exs` identifies framework entry points and generated modules. Do not remove an API based on a hint alone. To make findings fatal during a focused cleanup, run `MIX_ENV=test mix compile --force --severity warning --warnings-as-errors`.
- **Reach** enforces dependency direction through `.reach.exs` and `mix reach.check --arch`. The startup layer comes first because Reach assigns overlapping patterns to the first match. Use `mix reach.check --smells` and `mix reach.check --dead-code` for additional dependency/effect and unused-expression analysis.
- **Sobelow** fails on findings at every confidence level. `.sobelow-conf` excludes only the HTTPS configuration check because this template delegates TLS and redirects to the deployment proxy, as documented in `config/prod.exs`. Revisit this exception if hosting changes. A local skip on the fallback controller covers fixed error strings, not user-provided HTML.
- **Styler** runs through `mix format`. CI checks formatting without rewriting source. Gettext extraction must also be current; update catalogs with `mix gettext.extract` when messages change.

The browser pipelines set a minimal CSP for base URLs, embedded objects, and framing. Projects should choose script/style/connect policies alongside their actual frontend and provider requirements.

## Frontend

The suite runs oxfmt, oxlint, TypeScript (`bun run typecheck`), Vitest, and the Vite build from `assets/`.

## Template maintenance

When renaming the project, update the namespaces in `.reach.exs`, the Boundary declarations, and MixUnused's entry-point patterns in `mix.exs` along with the application modules.

The Arnor comparison found no additional quality tools. Its reusable simplicity and error-contract guidance was brought into `AGENTS.md` and `docs/CODE_STYLE_GUIDANCE.md`. Its GitHub OAuth integration, private icon dependency, and host-specific Xamal setup remain product choices. This baseline adds enforced CI and frontend type checking beyond either project's previous setup.

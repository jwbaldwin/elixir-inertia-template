# Elixir Inertia Template

Elixir Inertia Template is a reusable Phoenix/Inertia starter for small product teams. It pairs Phoenix's backend strength with Inertia's React ergonomics, so teams can build fast without splitting the product into a separate API and SPA.

The template includes the reusable foundation expected in many product apps: authentication, organizations, invitations, account settings, a small dashboard, CI scaffolding, deployment scaffolding, and strong agent guidance.

## Tech Stack

- Backend: Elixir, Phoenix, Ecto, PostgreSQL, Oban, Req
- Frontend: Inertia, React, TypeScript, Vite, Bun, Tailwind, shadcn components
- Testing: ExUnit, ExMachina, Mimic, Vitest
- Quality: ExCheck, Boundary, Credo, ExDNA, ExSlop, ExcellentMigrations, Jump Credo Checks, MixAudit, MixUnused, Reach, Sobelow, Styler, oxlint, oxfmt
- Deployment: Kamal

## Why Use This Template

Phoenix is the best framework in the world for owning routing, auth, persistence, background jobs, and server truth.

Inertia lets React consume that server truth with super fast and ergonomic DX. You get React pages, TypeScript props, server-side routing, normal controller tests, and no separate API layer unless your product actually needs one.

This template also includes strong opinionated agent guidance embedded throughout the repo:

- Architecture guidance in `AGENTS.md`
- Frontend guidance in `assets/AGENTS.md`
- Product and engineering decision rules in `docs/DESIGN_PRINCIPLES.md`
- Naming, testing, config, helper, and idempotency guidance in `docs/CODE_STYLE_GUIDANCE.md`
- Inertia TypeScript prop guidance in `docs/inertia-typescript-typing.md`
- Remote helper guidance in `docs/REMOTE_OPERATIONS.md`
- Extraction notes in `docs/TEMPLATE_INVENTORY.md`

## Included Product Foundation

- Email/password registration, login, logout, confirmation, and account settings via Phoenix sessions, signed tokens, and Inertia forms.
- Organizations, memberships, organization switching, invitations, and member removal.
- A small authenticated dashboard that proves Phoenix-to-Inertia props work.
- Local email preview in development and runtime production mailer config.
- Oban installed with a default queue, Lifeline, test config, and Oban Web mounted in dev.
- Seeds for a demo user and organization.

## Application Module Taxonomy

The reusable example domain is `lib/template_app/organizations`.

- `handlers/`: top-level orchestration for domain workflows.
- `services/`: action/write modules that do one operation and own side effects.
- `finders/`: read/query modules that do not write.
- `values/`: response and prop-shaping modules.
- contexts: CRUD-like schema operations, not business-process dumping grounds.
- workers: Oban durability boundaries that should call handlers, services, or finders.

Read `AGENTS.md` before adding real product code. The taxonomy there is a contract for future work, not optional style advice.

## Included As Scaffolding

- Kamal deployment files.
- Remote helper scripts: `bin/connect` and `bin/logs`.
- A starter dashboard to replace with the first real product page.

## Create A New Project

1. Copy this template directory into your new repository.
2. Replace the placeholder names:
   - `TemplateApp` with your Elixir module namespace, for example `AcmeApp`
   - `TemplateAppWeb` with your web namespace, for example `AcmeAppWeb`
   - `:template_app` with your OTP app atom, for example `:acme_app`
   - `template_app` in paths, release names, cookies, database names, and deployment service names
3. Update `README.md`, `AGENTS.md`, `.env.example`, `config/deploy.yml`, and package metadata for the new project.
4. Update `bin/connect` and `bin/logs` defaults if the deploy host, container pattern, or release binary changes.
5. Run `mix check` before first commit.

## Setup

Use the Elixir, Erlang, Bun, and PostgreSQL versions in `.mise.toml`. Install dependencies, create the database, and run migrations:

```sh
mix setup
```

Start the server:

```sh
mix phx.server
```

Open [`localhost:4000`](http://localhost:4000).

Seed an example organization and user if useful:

```sh
mix run priv/repo/seeds.exs
```

The seeded login is `demo@example.com` with password `TestPassword123`.

## Environment Variables

Use `.env.example` as the variable checklist. Local development loads `.env` and `.env.local` through `dotenvy`; both are gitignored.

Required in production:

- `DATABASE_URL`
- `SECRET_KEY_BASE`
- `PHX_HOST`

Optional runtime defaults:

- `PORT`, defaults to `4000`
- `POOL_SIZE`, defaults to `10`
- `DNS_CLUSTER_QUERY`
- `ECTO_IPV6`, set to `true` or `1` to enable IPv6 socket options

Generate a production secret with:

```sh
mix phx.gen.secret
```

## Testing And Linting

- Run `mix check` (or `mix precommit`) before handing off changes. CI runs the same checks.
- The suite checks compilation and boundaries, formatting, style, migrations, duplication, dependencies, security, architecture, backend/frontend tests, TypeScript, and the frontend build.
- Read [Quality Checks](docs/QUALITY_CHECKS.md) for tool settings, advisory checks, and scoped exceptions.
- Run `bun run lint` and `bun run test` from `assets/` for frontend changes.
- Run `bun run build` when changing imports, page resolution, Vite config, or deploy-facing assets.
- Prefer integration tests through controllers and real database writes when they prove more than isolated unit tests.
- Keep factories in `test/support/factory.ex` and reusable test helpers in `test/support/test_helpers.ex`.

## Deployment Notes

Kamal scaffolding is included, but deployment is intentionally not wired into CI.
Read [Deployment](docs/DEPLOYMENT.md) when adapting the release and Kamal sample to a real project.
Use `docs/REMOTE_OPERATIONS.md` before connecting `bin/connect` or `bin/logs` to a real host.
Choose hosting, secret storage, and rollback policy before enabling production deploys.

# Elixir Inertia Template

Elixir Inertia Template is a reusable Phoenix/Inertia starter for small product teams that want Phoenix to own routing, auth, persistence, background jobs, and server truth while React renders Inertia pages.

The template includes the reusable foundation expected in many product apps: authentication, organizations, invitations, account settings, a small dashboard, CI scaffolding, deployment scaffolding, and agent guidance.

## Tech Stack

- Backend: Elixir, Phoenix 1.8, Ecto, PostgreSQL, Oban, Swoosh, Req
- Frontend: Inertia, React, TypeScript, Vite, Bun, Tailwind, shadcn-style components
- Testing: ExUnit, Phoenix.ConnTest, ExMachina, Mimic, Vitest, LazyHTML
- Quality: Credo, Styler, oxlint, oxfmt
- Deployment: Dockerfile and optional Kamal config

## What This Template Is

This is an opinionated product starter, not a blank Phoenix app and not a framework.

It starts from a few beliefs:

- Phoenix should own routes, auth, persistence, background jobs, and server truth.
- React should render typed Inertia pages from server-provided props.
- Product code should grow in small vertical slices, not speculative architecture.
- Names should describe the human job being done, not API mechanics or generic data shapes.
- Deleted code is better than generic abstractions around behavior a product no longer needs.

## Included Product Foundation

- Email/password registration, login, logout, confirmation, and account settings.
- Organizations, memberships, organization switching, invitations, and member removal.
- A small authenticated dashboard that proves Phoenix-to-Inertia props work.
- Swoosh mailer setup with local mailbox in development and runtime production adapter config.
- Oban installed with a default queue, Lifeline, test config, and Oban Web mounted in dev.
- Health check endpoint at `/healthz`.
- Seeds for a demo user and organization.

## Opinionated Module Structure

The reusable example domain is `lib/template_app/organizations`.

- `handlers/`: top-level orchestration for domain workflows.
- `services/`: action/write modules that do one operation and own side effects.
- `finders/`: read/query modules that do not write.
- `values/`: response and prop-shaping modules.
- contexts: CRUD-like schema operations, not business-process dumping grounds.
- workers: Oban durability boundaries that should call handlers, services, or finders.

Read `AGENTS.md` before adding real product code. The taxonomy there is a contract for future work, not optional style advice.

## Agent Guidance And Docs

The template keeps the guidance close to the code because future agents should preserve the intended shape.

- `AGENTS.md`: project-level architecture, naming, testing, Phoenix, Ecto, Oban, and Inertia rules.
- `assets/AGENTS.md`: frontend-specific rules for React, Inertia props, layouts, and UI components.
- `docs/DESIGN_PRINCIPLES.md`: product and engineering decision rules.
- `docs/CODE_STYLE_GUIDANCE.md`: naming, tests, config, helpers, idempotency, and review preferences.
- `docs/inertia-typescript-typing.md`: how to keep Phoenix controller props and TypeScript page props aligned.
- `docs/REMOTE_OPERATIONS.md`: how to use and update `bin/connect` and `bin/logs`.
- `docs/TEMPLATE_INVENTORY.md`: what was kept, removed, and intentionally generalized.

## Library Choices

- Phoenix and Ecto for the server, routing, controller boundary, and database layer.
- Inertia for server-owned page state rendered by React.
- PostgreSQL as the database target.
- Oban for retryable background work.
- Swoosh for email.
- Req for outbound HTTP clients.
- Bodyguard for authorization policies.
- Dotenvy for local `.env` loading.
- Bandit as the Phoenix adapter.
- React, TypeScript, Vite, Bun, Tailwind, and shadcn-style components for the frontend.
- Radix UI, Headless UI, lucide-react, sonner, and small UI helpers for accessible interface primitives.
- ExUnit, Phoenix.ConnTest, ExMachina, Mimic, LazyHTML, and Vitest for tests.
- Credo, Styler, oxlint, and oxfmt for code quality.

## What Is Only Scaffolding

- CI currently does not enforce checks. It is a placeholder to fill in when a new project is ready.
- Dockerfile, Kamal config, `bin/connect`, and `bin/logs` assume a Docker/Kamal-style deploy but are optional.
- The dashboard is only a proof that authenticated Inertia pages work. Replace it with the first real product page.

## Create A New Project

1. Copy this template directory into your new repository.
2. Replace the placeholder names:
   - `TemplateApp` with your Elixir module namespace, for example `AcmeApp`
   - `TemplateAppWeb` with your web namespace, for example `AcmeAppWeb`
   - `:template_app` with your OTP app atom, for example `:acme_app`
   - `template_app` in paths, release names, cookies, database names, and deployment service names
3. Update `README.md`, `AGENTS.md`, `.env.example`, `config/deploy.yml`, and package metadata for the new project.
4. Update `bin/connect` and `bin/logs` defaults if the deploy host, container pattern, or release binary changes.
5. Run `mix format`, `mix test`, `mix fe.format`, `mix fe.lint`, and `mix fe.build` before first commit.

## Setup

Install backend dependencies, frontend dependencies, create the database, and run migrations:

```sh
mix setup
```

Start the server:

```sh
mix phx.server
```

Or with IEx:

```sh
iex -S mix phx.server
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

## Common Commands

Backend:

```sh
mix setup
mix phx.server
mix ecto.reset
mix test
mix lint
mix format --check-formatted
mix precommit
```

Frontend:

```sh
mix fe.setup
mix fe.build
mix fe.lint
mix fe.format
mix fe.format.check
```

From `assets/` directly:

```sh
bun install
bun run test
bun run lint
bun run format:check
bun run build
```

## Testing And Linting

- Run `mix precommit` before handing off backend changes.
- Run `bun run lint` and `bun run test` from `assets/` for frontend changes.
- Run `bun run build` when changing imports, page resolution, Vite config, or deploy-facing assets.
- Prefer integration tests through controllers and real database writes when they prove more than isolated unit tests.
- Keep factories in `test/support/factory.ex` and reusable test helpers in `test/support/test_helpers.ex`.

## Deployment Notes

The template includes a Dockerfile and optional Kamal config in `config/deploy.yml`.

It also includes remote helper scripts:

- `bin/connect` opens remote IEx inside the running app container.
- `bin/logs [tail_lines]` tails logs from the running app container.

See `docs/REMOTE_OPERATIONS.md` before wiring these helpers to a real host.

Kamal deployment expects these environment variables in the deploy environment:

- `KAMAL_IMAGE`
- `KAMAL_SERVER_IP`
- `KAMAL_REGISTRY_USERNAME`
- `KAMAL_REGISTRY_PASSWORD`
- `DATABASE_URL`
- `SECRET_KEY_BASE`
- `PHX_HOST`

CI intentionally does not auto-deploy. Wire deployment in a new project only after selecting hosting, secret storage, and rollback policy.

## Template Boundaries

This is not a framework. Keep it small.

- Add product domains under `lib/template_app/<domain>` when real product behavior exists.
- Keep Phoenix auth, organization membership, Inertia shared props, and the test conventions unless a new project deliberately chooses a different foundation.
- Keep the handler/service/finder/value taxonomy examples under `lib/template_app/organizations` until a real domain supersedes them.
- Delete the example dashboard once a real first product page exists.

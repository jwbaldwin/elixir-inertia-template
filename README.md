# Elixir Inertia Template

Elixir Inertia Template is a reusable Phoenix/Inertia starter for small product teams that want Phoenix to own routing, auth, persistence, background jobs, and server truth while React renders Inertia pages.

The template includes the reusable foundation expected in many product apps: authentication, organizations, invitations, account settings, a small dashboard, CI scaffolding, deployment scaffolding, and agent guidance.

## Tech Stack

- Backend: Elixir, Phoenix 1.8, Ecto, PostgreSQL, Oban, Swoosh, Req
- Frontend: Inertia, React, TypeScript, Vite, Bun, Tailwind, shadcn-style components
- Testing: ExUnit, Phoenix.ConnTest, ExMachina, Mimic, Vitest, LazyHTML
- Quality: Credo, Styler, oxlint, oxfmt
- Deployment: Dockerfile and optional Kamal config

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

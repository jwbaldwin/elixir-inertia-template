# Elixir Inertia Template Inventory

## Reusable Patterns Kept

- Phoenix owns routing, auth, persistence, background jobs, and server truth
- Inertia bridges Phoenix controllers to React pages through typed props
- Auth uses `current_scope` and router-level plugs
- Organizations, memberships, and invitations provide a reusable SaaS account foundation
- Backend modules use Context, Handler, Service, Finder, Value, and Worker roles
- Oban is installed for retryable background work with a default queue
- Tests use ConnCase/DataCase, centralized ExMachina factories, and shared helpers

## Tooling Kept

- Mix aliases for setup, frontend commands, linting, formatting, and precommit
- Phoenix, Ecto, PostgreSQL, Oban, Swoosh, Req, Bodyguard, dotenvy, Bandit
- Bun, Vite, React, TypeScript, Tailwind, shadcn-style UI primitives
- ExCheck, Boundary, Credo, ExDNA, ExSlop, ExcellentMigrations, Jump Credo Checks, MixAudit, MixUnused, Reach, Sobelow, Styler
- oxlint, oxfmt, TypeScript, Vitest
- GitHub Actions running the same `mix check` suite as local development
- Dockerfile and optional Kamal deployment sample

## Documentation Kept

- README onboarding contract
- Root `AGENTS.md` for architecture, testing, and preservation guidance
- `assets/AGENTS.md` for frontend-specific guidance
- Design principles and Inertia TypeScript typing notes
- Remote helper guidance in `docs/REMOTE_OPERATIONS.md`

## Removed Or Replaced

- Original product-domain implementations, provider integrations, eval artifacts, object-storage adapters, and local processing workflows
- Product migrations and product seed data
- Generated assets, build output, local env files, local tool state, and local input/output folders
- Product deployment workflow, proxy reboot workflow, private host names, and service-specific secret names
- Product docs and stale screenshots/artifacts

## Missing Pieces Added

- Generic README and `.env.example`
- Clean starter migrations
- Small authenticated dashboard example
- Template-specific agent guidance
- Generic remote helper documentation for `bin/connect` and `bin/logs`
- This extraction inventory

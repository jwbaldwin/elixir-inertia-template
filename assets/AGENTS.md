# Frontend Agent Guide

This folder is the frontend for a Phoenix app. Phoenix owns routes, auth, data, and server truth. Inertia carries that truth into React.

## Default Approach

- Keep the change small. Less code is usually better here
- Match the nearby file before inventing a new pattern
- Prefer editing a page or existing component over creating new abstractions
- Reuse the shadcn-style components in `js/components/ui` first
- Use Tailwind classes directly unless a shared component already exists
- Use `@/` imports and `cn()` from `@/lib/utils` for class merging
- Use lucide icons when adding icons
- Keep layouts flowing through `js/app.tsx`, `AppLayout`, and `AuthLayout`

## Inertia

- The server is the source of truth. Do not recreate server state in React
- Read page props with `usePage<Props>().props`
- Keep page prop types close to the page unless a model is reused across pages
- Update `js/types/models.ts` only when a shape is shared
- Use `useForm` for forms that submit back to Phoenix
- If a prop needs to change, make the smallest matching controller change and update TypeScript at the same time

## React

- Keep components boring and readable
- Do not add state unless the UI actually needs local interaction
- Do not add memoization by default. Reach for simpler component boundaries first
- Keep helper functions in the same file until there is real reuse
- Avoid new dependencies unless the project owner explicitly asks for one

## Do Not Drift Into Backend Work

- Do not change Phoenix routers, pipelines, auth, Ecto schemas, migrations, Oban workers, or domain modules for design polish
- If a design request seems to need backend work, stop and explain the smallest server-side change needed
- For frontend-only work, stay in `assets/js` unless an existing server prop truly needs to change

## Checks

- From `assets/`, run `bun run lint` after code changes
- Run `bun run test` when behavior changes
- Run `bun run build` when changing imports, routes, or build-facing code

# Inertia TypeScript Types

## Rule

Every controller that passes props to an Inertia page must have a matching TypeScript interface. When you add or change a route/controller, update the types.

## How It Works

### 1. Shared Props (global across all pages)

File: `assets/js/types/global.d.ts`

Augment Inertia's `InertiaConfig` with the shape of data shared on every request (auth, flash, etc.):

```typescript
declare module "@inertiajs/core" {
  export interface InertiaConfig {
    sharedPageProps: {
      auth: { user: { id: number; email: string } | null }
      flash: { info?: string; error?: string }
    }
    flashDataType: { info?: string; error?: string }
    errorValueType: string
  }
}
```

Update this file whenever you change shared data in the Inertia plug or router pipeline.

### 2. Per-Page Props (specific to each page)

Define the props interface in the same file as the page component:

```typescript
// assets/js/pages/app/projects.tsx
import { usePage } from "@inertiajs/react"

interface Props {
  projects: Project[]
}

export default function Index() {
  const { projects } = usePage<Props>().props
}
```

### 3. Shared Model Types

File: `assets/js/types/models.ts`

When the same entity appears on multiple pages, define it once:

```typescript
export interface Project {
  id: string
  name: string
  status: "active" | "archived"
  inserted_at: string
}

export interface User {
  id: number
  email: string
}
```

Import these in page components instead of re-defining inline.

## Checklist (for agents and humans)

When adding a new route or updating a controller:

1. Look at what `assign_prop` / `render_inertia` passes in the controller
2. If it's a new entity, add an interface to `assets/js/types/models.ts`
3. Define a `Props` interface in the page component file using those model types
4. If shared props changed (plug/pipeline), update `assets/js/types/global.d.ts`
5. Run `bunx tsc --noEmit` from `assets/` to verify

## File Locations

| What | Where |
|------|-------|
| Global shared props type | `assets/js/types/global.d.ts` |
| Domain model interfaces | `assets/js/types/models.ts` |
| Per-page prop interfaces | Same file as the page component |
| TypeScript config | `assets/tsconfig.json` |

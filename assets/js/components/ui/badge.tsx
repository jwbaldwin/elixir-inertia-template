import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";

import { cn } from "@/lib/utils";

const badgeVariants = cva(
  "inline-flex w-fit shrink-0 items-center justify-center gap-x-1.5 overflow-hidden whitespace-nowrap rounded-md px-1.5 py-0.5 text-sm/5 font-medium ring-1 ring-inset transition-colors forced-colors:outline sm:text-xs/5 [&>svg]:size-3 [&>svg]:pointer-events-none",
  {
    variants: {
      variant: {
        default:
          "bg-blue-500/15 text-blue-700 ring-blue-700/15 group-data-hover:bg-blue-500/25 dark:text-blue-400 dark:ring-blue-400/20",
        secondary:
          "bg-zinc-600/10 text-zinc-700 ring-zinc-700/15 group-data-hover:bg-zinc-600/20 dark:bg-white/5 dark:text-zinc-400 dark:ring-zinc-400/20",
        destructive:
          "bg-red-500/15 text-red-700 ring-red-700/15 group-data-hover:bg-red-500/25 dark:bg-red-500/10 dark:text-red-400 dark:ring-red-400/20",
        outline:
          "bg-zinc-600/10 text-zinc-700 ring-zinc-950/10 group-data-hover:bg-zinc-600/20 dark:bg-white/5 dark:text-zinc-400 dark:ring-white/10",
        success:
          "bg-lime-500/15 text-lime-600 ring-lime-600/15 group-data-hover:bg-lime-500/25 dark:bg-lime-500/10 dark:text-lime-400 dark:ring-lime-400/20",
        warning:
          "bg-amber-400/20 text-amber-700 ring-amber-700/15 group-data-hover:bg-amber-400/30 dark:bg-amber-400/10 dark:text-amber-400 dark:ring-amber-400/20",
        info: "bg-sky-500/15 text-sky-700 ring-sky-700/15 group-data-hover:bg-sky-500/25 dark:bg-sky-500/10 dark:text-sky-300 dark:ring-sky-300/20",
      },
    },
    defaultVariants: {
      variant: "default",
    },
  },
);

function Badge({
  className,
  variant,
  ...props
}: React.ComponentProps<"span"> & VariantProps<typeof badgeVariants>) {
  return (
    <span data-slot="badge" className={cn(badgeVariants({ variant }), className)} {...props} />
  );
}

export { Badge, badgeVariants };

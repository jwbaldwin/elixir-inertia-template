import type { PropsWithChildren, ReactNode } from "react";

import { usePage } from "@inertiajs/react";

import AppSidebar from "@/components/app-sidebar";
import { SidebarLayout } from "@/components/ui/sidebar-layout";
import FlashToasts from "@/components/flash-toasts";
import { TooltipProvider } from "@/components/ui/tooltip";
import { cn } from "@/lib/utils";
import type { SharedPageProps } from "@/types/models";

export interface AppLayoutProps {
  title: string;
  description?: string;
  className?: string;
  headerAction?: ReactNode;
}

export function withAppLayout(props: AppLayoutProps) {
  return function renderWithAppLayout(page: ReactNode) {
    return <AppLayout {...props}>{page}</AppLayout>;
  };
}

export default function AppLayout({
  title,
  description,
  className,
  headerAction,
  children,
}: PropsWithChildren<AppLayoutProps>) {
  const { flash } = usePage<SharedPageProps>().props;

  return (
    <TooltipProvider delayDuration={300}>
      <div className="min-h-screen bg-zinc-100 text-zinc-950">
        <FlashToasts flash={flash} />

        <SidebarLayout
          navbar={
            <div className="py-2.5 px-2">
              <p className="truncate text-sm/5 font-medium text-zinc-950 dark:text-white">
                {title}
              </p>
              {description ? (
                <p className="mt-0.5 truncate text-xs/5 text-zinc-500 dark:text-zinc-400">
                  {description}
                </p>
              ) : null}
            </div>
          }
          sidebar={<AppSidebar />}
        >
          <div className={cn("space-y-8", className)}>
            <div className="flex flex-wrap items-start justify-between gap-4">
              <div className="min-w-0">
                <h1 className="text-2xl font-semibold tracking-tight text-zinc-950 dark:text-white">
                  {title}
                </h1>
                {description ? (
                  <p className="mt-2 text-sm/6 text-zinc-600 dark:text-zinc-400">{description}</p>
                ) : null}
              </div>

              {headerAction ? <div className="shrink-0">{headerAction}</div> : null}
            </div>

            {children}
          </div>
        </SidebarLayout>
      </div>
    </TooltipProvider>
  );
}

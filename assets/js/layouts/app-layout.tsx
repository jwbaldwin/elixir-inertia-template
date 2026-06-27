import type { PropsWithChildren, ReactNode } from "react";

import { usePage } from "@inertiajs/react";

import AppSidebar from "@/components/app-sidebar";
import { SidebarLayout } from "@/components/ui/sidebar-layout";
import FlashToasts from "@/components/flash-toasts";
import { Heading } from "@/components/ui/heading";
import { Link } from "@/components/ui/link";
import { Text } from "@/components/ui/text";
import { TooltipProvider } from "@/components/ui/tooltip";
import { cn } from "@/lib/utils";
import type { SharedPageProps } from "@/types/models";

export interface AppLayoutTab {
  label: string;
  href: string;
  current?: boolean;
}

export interface AppLayoutProps {
  title: string;
  description?: string;
  className?: string;
  headerAction?: ReactNode;
  tabs?: AppLayoutTab[];
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
  tabs,
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
              <Text className="truncate font-medium text-zinc-950 dark:text-white">{title}</Text>
              {description ? (
                <Text className="mt-0.5 truncate text-xs/5 text-zinc-500 dark:text-zinc-400">
                  {description}
                </Text>
              ) : null}
            </div>
          }
          sidebar={<AppSidebar />}
        >
          <div className={cn("space-y-8", className)}>
            <div className="flex flex-wrap items-start justify-between gap-4">
              <div className="min-w-0">
                <Heading>{title}</Heading>
                {description ? <Text className="mt-2">{description}</Text> : null}
              </div>

              {headerAction ? <div className="shrink-0">{headerAction}</div> : null}
            </div>

            {tabs?.length ? <AppLayoutTabs tabs={tabs} /> : null}

            {children}
          </div>
        </SidebarLayout>
      </div>
    </TooltipProvider>
  );
}

function AppLayoutTabs({ tabs }: { tabs: AppLayoutTab[] }) {
  return (
    <div className="border-b border-zinc-950/10 dark:border-white/10">
      <nav aria-label="Section tabs" className="-mb-px flex gap-6 overflow-x-auto">
        {tabs.map((tab) => (
          <Link
            key={tab.href}
            href={tab.href}
            aria-current={tab.current ? "page" : undefined}
            className={cn(
              "relative whitespace-nowrap py-3 text-sm/6 font-medium text-zinc-500 transition hover:text-zinc-950 dark:text-zinc-400 dark:hover:text-white",
              tab.current && "text-zinc-950 dark:text-white",
            )}
          >
            {tab.label}
            {tab.current ? (
              <span className="absolute inset-x-0 bottom-0 h-0.5 rounded-full bg-zinc-950 dark:bg-white" />
            ) : null}
          </Link>
        ))}
      </nav>
    </div>
  );
}

import { Head, usePage } from "@inertiajs/react";

import { Heading, Subheading } from "@/components/ui/heading";
import { Text } from "@/components/ui/text";
import type { SharedPageProps } from "@/types/models";

interface DashboardPageProps extends SharedPageProps {
  organization_name: string | null;
}

export const pageMeta = {
  title: "Overview",
  description: "Your workspace command center",
  tabs: [{ label: "Overview", href: "/", current: true }],
} as const;

export default function Dashboard() {
  const { organization_name: organizationName, auth } = usePage<DashboardPageProps>().props;

  return (
    <>
      <Head title="Overview" />

      <div className="grid gap-6 lg:grid-cols-[minmax(0,1fr)_18rem]">
        <section className="rounded-2xl border border-zinc-950/10 bg-white p-6 shadow-xs dark:border-white/10 dark:bg-zinc-900">
          <div className="max-w-2xl">
            <Text className="font-medium">{organizationName ?? "No organization selected"}</Text>
            <Heading level={2} className="mt-2">
              Start building from this shell
            </Heading>
            <Text className="mt-3">
              The app frame, organization switcher, sidebar navigation, and dithered account avatar
              are in place. Product-specific content can replace this panel without touching the
              shell.
            </Text>
          </div>
        </section>

        <aside className="rounded-2xl border border-zinc-950/10 bg-zinc-50 p-6 dark:border-white/10 dark:bg-white/5">
          <Subheading>Signed in</Subheading>
          <Text className="mt-2 truncate">{auth.user.name}</Text>
          <Text className="truncate text-xs/5 text-zinc-500 dark:text-zinc-500">
            {auth.user.email}
          </Text>
        </aside>
      </div>
    </>
  );
}

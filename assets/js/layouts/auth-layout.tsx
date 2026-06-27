import type { PropsWithChildren } from "react";

import { usePage } from "@inertiajs/react";
import { Building2Icon } from "lucide-react";

import FlashToasts from "@/components/flash-toasts";
import { Heading } from "@/components/ui/heading";
import { Text } from "@/components/ui/text";
import type { UnauthenticatedPageProps } from "@/types/models";

interface AuthLayoutProps {
  title: string;
  description?: string;
}

export default function AuthLayout({
  title,
  description,
  children,
}: PropsWithChildren<AuthLayoutProps>) {
  const { flash } = usePage<UnauthenticatedPageProps>().props as UnauthenticatedPageProps;

  return (
    <div className="min-h-screen bg-muted/30">
      <FlashToasts flash={flash} />

      <main className="mx-auto flex min-h-screen w-full max-w-md items-center px-4 py-8">
        <div className="w-full rounded-2xl bg-white p-6 shadow-xs ring-1 ring-zinc-950/10 dark:bg-zinc-900 dark:ring-white/10">
          <div className="space-y-3">
            <div className="flex items-center gap-3">
              <div className="flex size-9 items-center justify-center rounded-md bg-zinc-950 text-white dark:bg-white dark:text-zinc-950">
                <Building2Icon className="size-4" />
              </div>
              <Text className="font-semibold tracking-wide text-zinc-950 dark:text-white">
                TemplateApp
              </Text>
            </div>
            <div className="space-y-1">
              <Heading>{title}</Heading>
              {description ? <Text>{description}</Text> : null}
            </div>
          </div>

          <div className="mt-6 space-y-6">{children}</div>
        </div>
      </main>
    </div>
  );
}

import type { PropsWithChildren } from "react";

import { usePage } from "@inertiajs/react";
import { Building2Icon } from "lucide-react";

import FlashToasts from "@/components/flash-toasts";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
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
        <Card className="w-full border-border/70 shadow-xs">
          <CardHeader className="space-y-3">
            <div className="flex items-center gap-3">
              <div className="bg-primary text-primary-foreground flex size-9 items-center justify-center rounded-md">
                <Building2Icon className="size-4" />
              </div>
              <p className="text-sm font-semibold tracking-wide">TemplateApp</p>
            </div>
            <div className="space-y-1">
              <CardTitle>{title}</CardTitle>
              {description && <CardDescription>{description}</CardDescription>}
            </div>
          </CardHeader>

          <CardContent className="space-y-6">{children}</CardContent>
        </Card>
      </main>
    </div>
  );
}

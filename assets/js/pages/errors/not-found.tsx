import { Head, usePage } from "@inertiajs/react";
import { ArrowLeftIcon, HomeIcon } from "lucide-react";

import { Button } from "@/components/ui/button";
import { Heading } from "@/components/ui/heading";
import { Text } from "@/components/ui/text";

interface NotFoundPageProps {
  [key: string]: unknown;

  status: number;
  message: string;
}

export default function NotFound() {
  const { status, message } = usePage<NotFoundPageProps>().props;

  return (
    <div className="min-h-screen bg-muted/30 px-4 py-8">
      <Head title="Page not found" />

      <main className="mx-auto flex min-h-[calc(100vh-4rem)] w-full max-w-lg items-center">
        <div className="w-full space-y-6 rounded-2xl bg-white p-6 shadow-xs ring-1 ring-zinc-950/10 dark:bg-zinc-900 dark:ring-white/10">
          <div className="space-y-3">
            <Text className="font-medium">{status}</Text>
            <div className="space-y-2">
              <Heading>{message}</Heading>
              <Text>The page you were looking for does not exist or is no longer available.</Text>
            </div>
          </div>

          <div className="flex flex-col gap-2 sm:flex-row">
            <Button href="/">
              <HomeIcon />
              Go home
            </Button>
            <Button type="button" outline onClick={() => window.history.back()}>
              <ArrowLeftIcon />
              Go back
            </Button>
          </div>
        </div>
      </main>
    </div>
  );
}

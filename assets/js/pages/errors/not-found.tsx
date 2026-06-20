import { Head, Link, usePage } from "@inertiajs/react";
import { ArrowLeftIcon, HomeIcon } from "lucide-react";

import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";

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
        <Card className="w-full border-border/70 shadow-xs">
          <CardContent className="space-y-6 pt-6">
            <div className="space-y-3">
              <p className="text-sm font-medium text-muted-foreground">{status}</p>
              <div className="space-y-2">
                <h1 className="text-2xl font-semibold tracking-tight">{message}</h1>
                <p className="text-sm leading-6 text-muted-foreground">
                  The page you were looking for does not exist or is no longer available.
                </p>
              </div>
            </div>

            <div className="flex flex-col gap-2 sm:flex-row">
              <Button asChild>
                <Link href="/">
                  <HomeIcon />
                  Go home
                </Link>
              </Button>
              <Button asChild variant="outline">
                <button type="button" onClick={() => window.history.back()}>
                  <ArrowLeftIcon />
                  Go back
                </button>
              </Button>
            </div>
          </CardContent>
        </Card>
      </main>
    </div>
  );
}

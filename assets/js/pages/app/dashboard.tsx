import { Head, usePage } from "@inertiajs/react";

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import type { SharedPageProps } from "@/types/models";

interface DashboardPageProps extends SharedPageProps {
  organization_name: string | null;
}

export const pageMeta = {
  title: "Dashboard",
  description: "A small authenticated Inertia page backed by Phoenix props",
} as const;

export default function Dashboard() {
  const { organization_name: organizationName, auth } = usePage<DashboardPageProps>().props;

  return (
    <>
      <Head title="Dashboard" />

      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader>
            <CardDescription>Signed in as</CardDescription>
            <CardTitle>{auth.user.name}</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-muted-foreground text-sm">{auth.user.email}</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardDescription>Active organization</CardDescription>
            <CardTitle>{organizationName ?? "No organization"}</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-muted-foreground text-sm">
              Organization switching is wired through shared Inertia props
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardDescription>Next step</CardDescription>
            <CardTitle>Replace this page</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-muted-foreground text-sm">
              Start new product work from routes, controllers, and focused domain modules
            </p>
          </CardContent>
        </Card>
      </div>
    </>
  );
}

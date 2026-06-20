import { Head, Link, useForm, usePage } from "@inertiajs/react";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Status } from "@/components/ui/status";
import { formatInvitationDateTime, formatInvitationLabel } from "@/lib/invitation-display";
import type { AppInvite, UnauthenticatedPageProps } from "@/types/models";

interface OrganizationInvitePageProps extends UnauthenticatedPageProps {
  token: string;
  login_url: string;
  state:
    | "ready"
    | "needs_login"
    | "email_mismatch"
    | "expired"
    | "closed"
    | "invalid"
    | "unconfirmed";
  invitation: AppInvite | null;
}

export const pageMeta = {
  title: "Organization invitation",
  description: "Review this invite before joining",
} as const;

export default function OrganizationInvite() {
  const {
    invitation,
    token,
    state,
    login_url: loginUrl,
    auth,
  } = usePage<OrganizationInvitePageProps>().props;
  const acceptForm = useForm({});

  const acceptInvitation = () => {
    acceptForm.post(`/org/invites/${token}/accept`);
  };

  return (
    <>
      <Head title="Organization invitation" />

      {invitation ? (
        <Card>
          <CardHeader>
            <CardTitle>{invitation.organization_name ?? "Organization"}</CardTitle>
            <CardDescription>
              {invitation.invited_by_email ?? "A teammate"} invited you as{" "}
              {formatInvitationLabel(invitation.role)}
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2 text-sm">
              <p>
                <span className="text-muted-foreground">Invited email:</span> {invitation.email}
              </p>
              <p>
                <span className="text-muted-foreground">Expires:</span>{" "}
                {formatInvitationDateTime(invitation.expires_at)}
              </p>
              <p>
                <span className="text-muted-foreground">Status:</span>{" "}
                <Status status={invitation.status} />
              </p>
            </div>

            {state === "ready" && (
              <Button type="button" disabled={acceptForm.processing} onClick={acceptInvitation}>
                {acceptForm.processing ? "Accepting..." : "Accept invitation"}
              </Button>
            )}

            {state === "needs_login" && (
              <Button asChild>
                <Link href={loginUrl}>Log in to continue</Link>
              </Button>
            )}

            {state === "email_mismatch" && (
              <p className="text-sm text-destructive">
                You are signed in as {auth.user?.email ?? "another account"}. This invitation was
                sent to {invitation.email}. Log in with that account to accept.
              </p>
            )}

            {state === "unconfirmed" && (
              <p className="text-sm text-destructive">
                Confirm your account email before accepting this invitation.
              </p>
            )}

            {state === "expired" && (
              <p className="text-sm text-destructive">
                This invitation has expired. Ask an organization admin to send a new one.
              </p>
            )}

            {state === "closed" && (
              <p className="text-sm text-destructive">
                This invitation is no longer pending. If you still need access, ask for a fresh
                invite.
              </p>
            )}
          </CardContent>
        </Card>
      ) : (
        <Card>
          <CardHeader>
            <CardTitle>Invite not found</CardTitle>
            <CardDescription>
              This invitation link is invalid or no longer available
            </CardDescription>
          </CardHeader>
        </Card>
      )}
    </>
  );
}

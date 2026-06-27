import { Head, useForm, usePage } from "@inertiajs/react";

import { Button } from "@/components/ui/button";
import {
  DescriptionDetails,
  DescriptionList,
  DescriptionTerm,
} from "@/components/ui/description-list";
import { Heading } from "@/components/ui/heading";
import { Status } from "@/components/ui/status";
import { Text } from "@/components/ui/text";
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
        <section className="rounded-2xl bg-white p-6 shadow-xs ring-1 ring-zinc-950/10 dark:bg-zinc-900 dark:ring-white/10">
          <div>
            <Heading>{invitation.organization_name ?? "Organization"}</Heading>
            <Text className="mt-1">
              {invitation.invited_by_email ?? "A teammate"} invited you as{" "}
              {formatInvitationLabel(invitation.role)}
            </Text>
          </div>

          <div className="mt-6 space-y-4">
            <DescriptionList>
              <DescriptionTerm>Invited email</DescriptionTerm>
              <DescriptionDetails>{invitation.email}</DescriptionDetails>
              <DescriptionTerm>Expires</DescriptionTerm>
              <DescriptionDetails>
                {formatInvitationDateTime(invitation.expires_at)}
              </DescriptionDetails>
              <DescriptionTerm>Status</DescriptionTerm>
              <DescriptionDetails>
                <Status status={invitation.status} />
              </DescriptionDetails>
            </DescriptionList>

            {state === "ready" && (
              <Button type="button" disabled={acceptForm.processing} onClick={acceptInvitation}>
                {acceptForm.processing ? "Accepting..." : "Accept invitation"}
              </Button>
            )}

            {state === "needs_login" && <Button href={loginUrl}>Log in to continue</Button>}

            {state === "email_mismatch" && (
              <Text className="text-red-600 dark:text-red-500">
                You are signed in as {auth.user?.email ?? "another account"}. This invitation was
                sent to {invitation.email}. Log in with that account to accept.
              </Text>
            )}

            {state === "unconfirmed" && (
              <Text className="text-red-600 dark:text-red-500">
                Confirm your account email before accepting this invitation.
              </Text>
            )}

            {state === "expired" && (
              <Text className="text-red-600 dark:text-red-500">
                This invitation has expired. Ask an organization admin to send a new one.
              </Text>
            )}

            {state === "closed" && (
              <Text className="text-red-600 dark:text-red-500">
                This invitation is no longer pending. If you still need access, ask for a fresh
                invite.
              </Text>
            )}
          </div>
        </section>
      ) : (
        <section className="rounded-2xl bg-white p-6 shadow-xs ring-1 ring-zinc-950/10 dark:bg-zinc-900 dark:ring-white/10">
          <Heading>Invite not found</Heading>
          <Text className="mt-1">This invitation link is invalid or no longer available</Text>
        </section>
      )}
    </>
  );
}

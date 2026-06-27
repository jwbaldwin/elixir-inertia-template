import { Head, useForm, usePage } from "@inertiajs/react";
import type { FormEvent } from "react";

import {
  formatInvitationDateTime as format_invitation_date_time,
  formatInvitationLabel as format_invitation_label,
} from "@/lib/invitation-display";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  DescriptionDetails,
  DescriptionList,
  DescriptionTerm,
} from "@/components/ui/description-list";
import { Divider } from "@/components/ui/divider";
import { ErrorMessage, Field, Label } from "@/components/ui/fieldset";
import { Heading, Subheading } from "@/components/ui/heading";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Text } from "@/components/ui/text";
import type {
  AppInvite,
  AppOrganization,
  AppOrganizationMember,
  SharedPageProps,
} from "@/types/models";

interface OrganizationSettingsPageProps extends SharedPageProps {
  organization: AppOrganization;
  invitations: AppInvite[];
  members: AppOrganizationMember[];
  can_edit: boolean;
  form: {
    email: string;
    role: string;
  };
}

export const pageMeta = {
  title: "Organization settings",
  description: "Invite members and manage pending invitations",
  className: "max-w-4xl space-y-6",
} as const;

export default function OrganizationSettings() {
  const {
    organization,
    invitations,
    members,
    can_edit,
    form: initial_form,
    errors,
    auth,
  } = usePage<OrganizationSettingsPageProps>().props;

  const organization_form = useForm({ name: organization.name });

  const invite_form = useForm({
    email: initial_form.email,
    role: initial_form.role === "admin" ? "admin" : "member",
  });

  const current_user_id = auth.user.id;

  const submit_organization = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();

    organization_form.transform((data) => ({ organization: data }));
    organization_form.put("/org/settings", {
      preserveScroll: true,
    });
  };

  const submit_invitation = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();

    if (!can_edit) {
      return;
    }

    invite_form.transform((data) => ({ invitation: data }));
    invite_form.post("/org/settings/invitations", {
      preserveScroll: true,
      onSuccess: () => {
        invite_form.setData("email", "");
        invite_form.setData("role", "member");
      },
    });
  };

  const invitation_rows: AppInvite[] = invitations ?? [];
  const member_rows: AppOrganizationMember[] = members ?? [];

  return (
    <>
      <Head title="Organization settings" />

      <section className="rounded-2xl bg-white p-6 shadow-xs ring-1 ring-zinc-950/10 dark:bg-zinc-900 dark:ring-white/10">
        <div>
          <Heading level={2}>Organization</Heading>
          <Text className="mt-1">Set the name your team sees across the app</Text>
        </div>

        <div className="mt-6">
          {can_edit ? (
            <form id="organization-name-form" onSubmit={submit_organization} className="space-y-4">
              <div className="grid gap-4 sm:grid-cols-[minmax(0,1fr)_auto] sm:items-end">
                <Field>
                  <Label htmlFor="organization-name">Name</Label>
                  <Input
                    id="organization-name"
                    value={organization_form.data.name}
                    onChange={(event) => organization_form.setData("name", event.target.value)}
                    disabled={organization_form.processing}
                  />
                </Field>

                <Button type="submit" disabled={organization_form.processing}>
                  {organization_form.processing ? "Saving..." : "Save"}
                </Button>
              </div>

              {errors.name ? <ErrorMessage>{errors.name}</ErrorMessage> : null}
            </form>
          ) : (
            <DescriptionList>
              <DescriptionTerm>Name</DescriptionTerm>
              <DescriptionDetails>{organization.name}</DescriptionDetails>
            </DescriptionList>
          )}
        </div>
      </section>

      <section className="rounded-2xl bg-white p-6 shadow-xs ring-1 ring-zinc-950/10 dark:bg-zinc-900 dark:ring-white/10">
        <div>
          <Subheading>Organization users</Subheading>
          <Text className="mt-1">Current members and roles in this organization</Text>
        </div>

        <div className="mt-6">
          <Table dense>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Email</TableHead>
                <TableHead>Role</TableHead>
                <TableHead>Joined</TableHead>
                {can_edit ? <TableHead className="text-right">Action</TableHead> : null}
              </TableRow>
            </TableHeader>
            <TableBody>
              {member_rows.length === 0 ? (
                <TableRow>
                  <TableCell
                    colSpan={can_edit ? 5 : 4}
                    className="h-20 text-center text-zinc-500 dark:text-zinc-400"
                  >
                    No users in this organization yet
                  </TableCell>
                </TableRow>
              ) : (
                member_rows.map((member) => (
                  <TableRow key={member.id}>
                    <TableCell className="font-medium">{member.name}</TableCell>
                    <TableCell>{member.email}</TableCell>
                    <TableCell>
                      <Badge color="zinc">{format_invitation_label(member.role)}</Badge>
                    </TableCell>
                    <TableCell>{format_invitation_date_time(member.joined_at)}</TableCell>
                    {can_edit ? (
                      <TableCell className="text-right">
                        {member.user_id === current_user_id ? null : (
                          <Button
                            href={`/org/settings/members/${member.id}`}
                            method="delete"
                            as="button"
                            preserveScroll
                            outline
                          >
                            Remove
                          </Button>
                        )}
                      </TableCell>
                    ) : null}
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </div>
      </section>

      <section className="rounded-2xl bg-white p-6 shadow-xs ring-1 ring-zinc-950/10 dark:bg-zinc-900 dark:ring-white/10">
        <div>
          <Subheading>Invites</Subheading>
          <Text className="mt-1">Invite teammates to {organization.name}</Text>
        </div>

        <div className="mt-6 space-y-6">
          {can_edit ? (
            <form id="organization-invite-form" onSubmit={submit_invitation} className="space-y-4">
              <div className="grid gap-4 sm:grid-cols-[minmax(0,1fr)_auto_auto] sm:items-end">
                <Field>
                  <Label htmlFor="org-invite-email">Email</Label>
                  <Input
                    id="org-invite-email"
                    type="email"
                    autoComplete="email"
                    required
                    value={invite_form.data.email}
                    onChange={(event) => invite_form.setData("email", event.target.value)}
                  />
                </Field>

                <Field className="sm:w-36">
                  <Label htmlFor="org-invite-role">Role</Label>
                  <Select
                    id="org-invite-role"
                    value={invite_form.data.role}
                    onChange={(event) => invite_form.setData("role", event.target.value)}
                  >
                    <option value="member">Member</option>
                    <option value="admin">Admin</option>
                  </Select>
                </Field>

                <Button type="submit" disabled={invite_form.processing}>
                  {invite_form.processing ? "Sending..." : "Send invite"}
                </Button>
              </div>

              {errors.email ? <ErrorMessage>{errors.email}</ErrorMessage> : null}
              {errors.role ? <ErrorMessage>{errors.role}</ErrorMessage> : null}
            </form>
          ) : (
            <Text>Only organization admins can send or cancel invitations.</Text>
          )}

          <Divider soft />

          <Table dense>
            <TableHeader>
              <TableRow>
                <TableHead>Email</TableHead>
                <TableHead>Role</TableHead>
                <TableHead>Invited by</TableHead>
                <TableHead>Sent</TableHead>
                <TableHead>Expires</TableHead>
                {can_edit ? (
                  <TableHead className="sticky right-0 z-20 border-l border-zinc-950/10 bg-white text-right shadow-[-6px_0_10px_-8px_rgba(15,23,42,0.35)] before:pointer-events-none before:absolute before:inset-y-0 before:-left-3 before:w-3 before:bg-gradient-to-l before:from-white/45 before:to-transparent before:content-[''] dark:border-white/10 dark:bg-zinc-900 dark:before:from-zinc-900/45">
                    Action
                  </TableHead>
                ) : null}
              </TableRow>
            </TableHeader>
            <TableBody>
              {invitation_rows.length === 0 ? (
                <TableRow>
                  <TableCell
                    colSpan={can_edit ? 6 : 5}
                    className="h-20 text-center text-zinc-500 dark:text-zinc-400"
                  >
                    No pending invitations
                  </TableCell>
                </TableRow>
              ) : (
                invitation_rows.map((invitation) => (
                  <TableRow key={invitation.id}>
                    <TableCell className="font-medium">{invitation.email}</TableCell>
                    <TableCell>
                      <Badge color="zinc">{format_invitation_label(invitation.role)}</Badge>
                    </TableCell>
                    <TableCell>{invitation.invited_by_email ?? "--"}</TableCell>
                    <TableCell>{format_invitation_date_time(invitation.inserted_at)}</TableCell>
                    <TableCell>{format_invitation_date_time(invitation.expires_at)}</TableCell>
                    {can_edit ? (
                      <TableCell className="sticky right-0 z-10 border-l border-zinc-950/10 bg-white text-right shadow-[-6px_0_10px_-8px_rgba(15,23,42,0.35)] before:pointer-events-none before:absolute before:inset-y-0 before:-left-3 before:w-3 before:bg-gradient-to-l before:from-white/45 before:to-transparent before:content-[''] dark:border-white/10 dark:bg-zinc-900 dark:before:from-zinc-900/45">
                        <Button
                          href={`/org/settings/invitations/${invitation.id}`}
                          method="delete"
                          as="button"
                          preserveScroll
                          outline
                        >
                          Cancel
                        </Button>
                      </TableCell>
                    ) : null}
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </div>
      </section>
    </>
  );
}

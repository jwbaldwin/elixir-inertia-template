import { Head, Link, useForm, usePage } from "@inertiajs/react";
import type { FormEvent } from "react";

import {
  formatInvitationDateTime as format_invitation_date_time,
  formatInvitationLabel as format_invitation_label,
} from "@/lib/invitation-display";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
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

      <Card>
        <CardHeader>
          <CardTitle>Organization</CardTitle>
          <CardDescription>Set the name your team sees across the app</CardDescription>
        </CardHeader>
        <CardContent>
          {can_edit ? (
            <form id="organization-name-form" onSubmit={submit_organization} className="space-y-4">
              <div className="grid gap-4 sm:grid-cols-[minmax(0,1fr)_auto] sm:items-end">
                <div>
                  <Label className="mb-2" htmlFor="organization-name">
                    Name
                  </Label>
                  <Input
                    id="organization-name"
                    value={organization_form.data.name}
                    onChange={(event) => organization_form.setData("name", event.target.value)}
                    disabled={organization_form.processing}
                  />
                </div>

                <Button type="submit" disabled={organization_form.processing} className="h-10">
                  {organization_form.processing ? "Saving..." : "Save"}
                </Button>
              </div>

              {errors.name && <p className="text-sm text-destructive">{errors.name}</p>}
            </form>
          ) : (
            <div className="space-y-1">
              <p className="text-muted-foreground text-sm">Name</p>
              <p className="font-medium">{organization.name}</p>
            </div>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Organization users</CardTitle>
          <CardDescription>Current members and roles in this organization</CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
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
                    className="text-muted-foreground h-20 text-center"
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
                      <Badge variant="secondary">{format_invitation_label(member.role)}</Badge>
                    </TableCell>
                    <TableCell>{format_invitation_date_time(member.joined_at)}</TableCell>
                    {can_edit ? (
                      <TableCell className="text-right">
                        {member.user_id === current_user_id ? null : (
                          <Button asChild variant="outline" size="sm">
                            <Link
                              href={`/org/settings/members/${member.id}`}
                              method="delete"
                              as="button"
                              preserveScroll
                            >
                              Remove
                            </Link>
                          </Button>
                        )}
                      </TableCell>
                    ) : null}
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Invites</CardTitle>
          <CardDescription>Invite teammates to {organization.name}</CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          {can_edit ? (
            <form id="organization-invite-form" onSubmit={submit_invitation} className="space-y-4">
              <div className="grid gap-4 border-b border-border pb-6 sm:grid-cols-[minmax(0,1fr)_auto_auto] sm:items-end">
                <div>
                  <Label className="mb-2" htmlFor="org-invite-email">
                    Email
                  </Label>
                  <Input
                    id="org-invite-email"
                    type="email"
                    autoComplete="email"
                    required
                    value={invite_form.data.email}
                    onChange={(event) => invite_form.setData("email", event.target.value)}
                  />
                </div>

                <div className="sm:w-36">
                  <Label className="mb-2" htmlFor="org-invite-role">
                    Role
                  </Label>
                  <Select
                    value={invite_form.data.role}
                    onValueChange={(value) => invite_form.setData("role", value)}
                  >
                    <SelectTrigger id="org-invite-role" className="w-full data-[size=default]:h-10">
                      <SelectValue placeholder="Select role" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="member">Member</SelectItem>
                      <SelectItem value="admin">Admin</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <Button className="h-10" type="submit" disabled={invite_form.processing}>
                  {invite_form.processing ? "Sending..." : "Send invite"}
                </Button>
              </div>

              {errors.email && <p className="text-sm text-destructive">{errors.email}</p>}
              {errors.role && <p className="text-sm text-destructive">{errors.role}</p>}
            </form>
          ) : (
            <p className="text-muted-foreground border-b border-border pb-6 text-sm">
              Only organization admins can send or cancel invitations.
            </p>
          )}

          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Email</TableHead>
                <TableHead>Role</TableHead>
                <TableHead>Invited by</TableHead>
                <TableHead>Sent</TableHead>
                <TableHead>Expires</TableHead>
                {can_edit ? (
                  <TableHead className="sticky right-0 z-20 border-l border-border bg-card text-right shadow-[-6px_0_10px_-8px_rgba(15,23,42,0.35)] before:pointer-events-none before:absolute before:inset-y-0 before:-left-3 before:w-3 before:bg-gradient-to-l before:from-card/45 before:to-transparent before:content-['']">
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
                    className="text-muted-foreground h-20 text-center"
                  >
                    No pending invitations
                  </TableCell>
                </TableRow>
              ) : (
                invitation_rows.map((invitation) => (
                  <TableRow key={invitation.id}>
                    <TableCell className="font-medium">{invitation.email}</TableCell>
                    <TableCell>
                      <Badge variant="secondary">{format_invitation_label(invitation.role)}</Badge>
                    </TableCell>
                    <TableCell>{invitation.invited_by_email ?? "--"}</TableCell>
                    <TableCell>{format_invitation_date_time(invitation.inserted_at)}</TableCell>
                    <TableCell>{format_invitation_date_time(invitation.expires_at)}</TableCell>
                    {can_edit ? (
                      <TableCell className="sticky right-0 z-10 border-l border-border bg-card text-right shadow-[-6px_0_10px_-8px_rgba(15,23,42,0.35)] before:pointer-events-none before:absolute before:inset-y-0 before:-left-3 before:w-3 before:bg-gradient-to-l before:from-card/45 before:to-transparent before:content-['']">
                        <Button asChild variant="outline" size="sm">
                          <Link
                            href={`/org/settings/invitations/${invitation.id}`}
                            method="delete"
                            as="button"
                            preserveScroll
                          >
                            Cancel
                          </Link>
                        </Button>
                      </TableCell>
                    ) : null}
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </>
  );
}

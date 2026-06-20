import { Head, useForm, usePage } from "@inertiajs/react";
import type { FormEvent } from "react";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import type { SharedPageProps } from "@/types/models";

interface AccountSettingsPageProps extends SharedPageProps {
  email: string;
  active_form?: "email" | "password";
}

export const pageMeta = {
  title: "Account settings",
  description: "Manage your email address and password",
  className: "max-w-3xl space-y-6",
} as const;

export default function AccountSettings() {
  const { email, errors, active_form: activeForm } = usePage<AccountSettingsPageProps>().props;

  const emailForm = useForm({ email });
  const passwordForm = useForm({ password: "", password_confirmation: "" });

  const updateEmail = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    emailForm.transform((data) => ({ action: "update_email", user: data }));
    emailForm.put("/users/settings", { preserveScroll: true });
  };

  const updatePassword = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    passwordForm.transform((data) => ({ action: "update_password", user: data }));
    passwordForm.put("/users/settings", {
      preserveScroll: true,
      onFinish: () => {
        passwordForm.setData("password", "");
        passwordForm.setData("password_confirmation", "");
      },
    });
  };

  return (
    <>
      <Head title="Settings" />

      <Card>
        <CardHeader>
          <CardTitle>Email</CardTitle>
          <CardDescription>Update the email tied to this account</CardDescription>
        </CardHeader>
        <CardContent>
          <form id="settings-email-form" onSubmit={updateEmail} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="settings-email">Email</Label>
              <Input
                id="settings-email"
                type="email"
                required
                autoComplete="email"
                value={emailForm.data.email}
                onChange={(event) => emailForm.setData("email", event.target.value)}
              />
              {errors.email && <p className="text-sm text-destructive">{errors.email}</p>}
            </div>

            <Button type="submit" disabled={emailForm.processing}>
              {emailForm.processing ? "Saving..." : "Change email"}
            </Button>
          </form>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Password</CardTitle>
          <CardDescription>Set a new password for this account</CardDescription>
        </CardHeader>
        <CardContent>
          <form id="settings-password-form" onSubmit={updatePassword} className="space-y-4">
            {activeForm == "password" && errors.email ? (
              <p className="text-sm text-destructive">{errors.email}</p>
            ) : null}

            <div className="space-y-2">
              <Label htmlFor="settings-password">New password</Label>
              <Input
                id="settings-password"
                type="password"
                required
                autoComplete="new-password"
                value={passwordForm.data.password}
                onChange={(event) => passwordForm.setData("password", event.target.value)}
              />
              {errors.password && <p className="text-sm text-destructive">{errors.password}</p>}
            </div>

            <div className="space-y-2">
              <Label htmlFor="settings-password-confirmation">Confirm new password</Label>
              <Input
                id="settings-password-confirmation"
                type="password"
                required
                autoComplete="new-password"
                value={passwordForm.data.password_confirmation}
                onChange={(event) =>
                  passwordForm.setData("password_confirmation", event.target.value)
                }
              />
              {errors.password_confirmation ? (
                <p className="text-sm text-destructive">{errors.password_confirmation}</p>
              ) : null}
            </div>

            <Button type="submit" disabled={passwordForm.processing}>
              {passwordForm.processing ? "Saving..." : "Save password"}
            </Button>
          </form>
        </CardContent>
      </Card>
    </>
  );
}

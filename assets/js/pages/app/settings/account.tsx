import { Head, useForm, usePage } from "@inertiajs/react";
import type { FormEvent } from "react";

import { Button } from "@/components/ui/button";
import { ErrorMessage, Field, Label } from "@/components/ui/fieldset";
import { Heading, Subheading } from "@/components/ui/heading";
import { Input } from "@/components/ui/input";
import { Text } from "@/components/ui/text";
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

      <section className="rounded-2xl bg-white p-6 shadow-xs ring-1 ring-zinc-950/10 dark:bg-zinc-900 dark:ring-white/10">
        <div>
          <Heading level={2}>Email</Heading>
          <Text className="mt-1">Update the email tied to this account</Text>
        </div>

        <div className="mt-6">
          <form id="settings-email-form" onSubmit={updateEmail} className="space-y-4">
            <Field>
              <Label htmlFor="settings-email">Email</Label>
              <Input
                id="settings-email"
                type="email"
                required
                autoComplete="email"
                value={emailForm.data.email}
                onChange={(event) => emailForm.setData("email", event.target.value)}
              />
              {errors.email ? <ErrorMessage>{errors.email}</ErrorMessage> : null}
            </Field>

            <Button type="submit" disabled={emailForm.processing}>
              {emailForm.processing ? "Saving..." : "Change email"}
            </Button>
          </form>
        </div>
      </section>

      <section className="rounded-2xl bg-white p-6 shadow-xs ring-1 ring-zinc-950/10 dark:bg-zinc-900 dark:ring-white/10">
        <div>
          <Subheading>Password</Subheading>
          <Text className="mt-1">Set a new password for this account</Text>
        </div>

        <div className="mt-6">
          <form id="settings-password-form" onSubmit={updatePassword} className="space-y-4">
            {activeForm == "password" && errors.email ? (
              <ErrorMessage>{errors.email}</ErrorMessage>
            ) : null}

            <Field>
              <Label htmlFor="settings-password">New password</Label>
              <Input
                id="settings-password"
                type="password"
                required
                autoComplete="new-password"
                value={passwordForm.data.password}
                onChange={(event) => passwordForm.setData("password", event.target.value)}
              />
              {errors.password ? <ErrorMessage>{errors.password}</ErrorMessage> : null}
            </Field>

            <Field>
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
                <ErrorMessage>{errors.password_confirmation}</ErrorMessage>
              ) : null}
            </Field>

            <Button type="submit" disabled={passwordForm.processing}>
              {passwordForm.processing ? "Saving..." : "Save password"}
            </Button>
          </form>
        </div>
      </section>
    </>
  );
}

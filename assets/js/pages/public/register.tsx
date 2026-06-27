import { Head, useForm, usePage } from "@inertiajs/react";
import type { FormEvent } from "react";

import { Button } from "@/components/ui/button";
import { ErrorMessage, Field, Label } from "@/components/ui/fieldset";
import { Input } from "@/components/ui/input";
import { Text, TextLink } from "@/components/ui/text";
import type { UnauthenticatedPageProps } from "@/types/models";

interface RegisterPageProps extends UnauthenticatedPageProps {
  form: {
    name: string;
    email: string;
    company_name: string;
    password: string;
    password_confirmation: string;
  };
}

export const pageMeta = {
  title: "Create account",
  description: "Sign up and we will send a confirmation link before your first login",
} as const;

export default function Register() {
  const { form: initialForm, errors } = usePage<RegisterPageProps>().props;
  const companyNameError = errors.company_name ?? errors.name ?? errors.slug;

  const form = useForm({
    name: initialForm.name ?? "",
    email: initialForm.email ?? "",
    company_name: initialForm.company_name ?? "",
    password: initialForm.password ?? "",
    password_confirmation: initialForm.password_confirmation ?? "",
  });

  const submit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    form.transform((data) => ({ user: data }));
    form.post("/register", { preserveScroll: true });
  };

  return (
    <>
      <Head title="Register" />

      <form id="register-form" onSubmit={submit} className="space-y-4">
        <Field>
          <Label htmlFor="register-name">Your name</Label>
          <Input
            id="register-name"
            type="text"
            required
            autoComplete="name"
            value={form.data.name}
            onChange={(event) => form.setData("name", event.target.value)}
          />
          {errors.name ? <ErrorMessage>{errors.name}</ErrorMessage> : null}
        </Field>

        <Field>
          <Label htmlFor="register-company-name">Company name</Label>
          <Input
            id="register-company-name"
            type="text"
            required
            autoComplete="organization"
            value={form.data.company_name}
            onChange={(event) => form.setData("company_name", event.target.value)}
          />
          {companyNameError ? <ErrorMessage>{companyNameError}</ErrorMessage> : null}
        </Field>

        <Field>
          <Label htmlFor="register-email">Email</Label>
          <Input
            id="register-email"
            type="email"
            required
            autoComplete="email"
            value={form.data.email}
            onChange={(event) => form.setData("email", event.target.value)}
          />
          {errors.email ? <ErrorMessage>{errors.email}</ErrorMessage> : null}
        </Field>

        <Field>
          <Label htmlFor="register-password">Password</Label>
          <Input
            id="register-password"
            type="password"
            required
            autoComplete="new-password"
            value={form.data.password}
            onChange={(event) => form.setData("password", event.target.value)}
          />
          {errors.password ? <ErrorMessage>{errors.password}</ErrorMessage> : null}
        </Field>

        <Field>
          <Label htmlFor="register-password-confirmation">Confirm password</Label>
          <Input
            id="register-password-confirmation"
            type="password"
            required
            autoComplete="new-password"
            value={form.data.password_confirmation}
            onChange={(event) => form.setData("password_confirmation", event.target.value)}
          />
          {errors.password_confirmation && (
            <ErrorMessage>{errors.password_confirmation}</ErrorMessage>
          )}
        </Field>

        <Button type="submit" disabled={form.processing} className="w-full">
          {form.processing ? "Creating account..." : "Create account"}
        </Button>
      </form>

      <Text className="mt-4">
        Already registered? <TextLink href="/login">Log in</TextLink>
      </Text>
    </>
  );
}

import { Head, useForm, usePage } from "@inertiajs/react";

import { Button } from "@/components/ui/button";
import { Checkbox, CheckboxField } from "@/components/ui/checkbox";
import { ErrorMessage, Field, Label } from "@/components/ui/fieldset";
import { Input } from "@/components/ui/input";
import { Code, Text, TextLink } from "@/components/ui/text";
import type { UnauthenticatedPageProps } from "@/types/models";

interface LoginPageProps extends UnauthenticatedPageProps {
  form: {
    email: string;
  };
  local_mail_adapter: boolean;
}

export const pageMeta = {
  title: "Log in",
  description: "Use your email and password to access your account",
} as const;

export default function Login() {
  const {
    form: initialForm,
    errors,
    local_mail_adapter: localMailAdapter,
  } = usePage<LoginPageProps>().props;

  const passwordForm = useForm({
    email: initialForm.email ?? "",
    password: "",
    remember_me: false,
  });

  const logInWithPassword = () => {
    passwordForm.transform((data) => ({
      user: {
        email: data.email,
        password: data.password,
        remember_me: data.remember_me,
      },
    }));

    passwordForm.post("/login", {
      preserveScroll: true,
      onFinish: () => passwordForm.setData("password", ""),
    });
  };

  return (
    <>
      <Head title="Log in" />

      {localMailAdapter && (
        <Text className="rounded-lg bg-blue-500/15 px-3 py-2 text-blue-700 dark:bg-blue-500/10 dark:text-blue-300">
          Confirmation emails are sent to the local adapter in development. Check{" "}
          <Code>/dev/mailbox</Code>
        </Text>
      )}

      <form
        id="password-login-form"
        onSubmit={(event) => {
          event.preventDefault();
          logInWithPassword();
        }}
        className="space-y-4"
      >
        <Field>
          <Label htmlFor="password-email">Email</Label>
          <Input
            id="password-email"
            type="email"
            required
            autoComplete="email"
            value={passwordForm.data.email}
            onChange={(event) => passwordForm.setData("email", event.target.value)}
          />
          {errors.email ? <ErrorMessage>{errors.email}</ErrorMessage> : null}
        </Field>

        <Field>
          <Label htmlFor="password-value">Password</Label>
          <Input
            id="password-value"
            type="password"
            autoComplete="current-password"
            value={passwordForm.data.password}
            onChange={(event) => passwordForm.setData("password", event.target.value)}
          />
          {errors.password ? <ErrorMessage>{errors.password}</ErrorMessage> : null}
        </Field>

        <CheckboxField>
          <Checkbox
            id="remember-me"
            checked={passwordForm.data.remember_me}
            onChange={(checked) => passwordForm.setData("remember_me", checked)}
          />
          <Label htmlFor="remember-me">Remember me</Label>
        </CheckboxField>

        <div>
          <Button type="submit" disabled={passwordForm.processing} className="w-full">
            {passwordForm.processing ? "Logging in..." : "Log in"}
          </Button>
        </div>
      </form>
      <Text>
        Don&apos;t have an account? <TextLink href="/register">Sign up</TextLink>
      </Text>
    </>
  );
}

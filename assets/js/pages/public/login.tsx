import { Head, Link, useForm, usePage } from "@inertiajs/react";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
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
        <div className="rounded-md border border-blue-200 bg-blue-50 px-3 py-2 text-sm text-blue-900">
          Confirmation emails are sent to the local adapter in development. Check{" "}
          <code>/dev/mailbox</code>
        </div>
      )}

      <form
        id="password-login-form"
        onSubmit={(event) => {
          event.preventDefault();
          logInWithPassword();
        }}
        className="space-y-4"
      >
        <div className="space-y-2">
          <Label htmlFor="password-email">Email</Label>
          <Input
            id="password-email"
            type="email"
            required
            autoComplete="email"
            value={passwordForm.data.email}
            onChange={(event) => passwordForm.setData("email", event.target.value)}
          />
          {errors.email && <p className="text-sm text-destructive">{errors.email}</p>}
        </div>

        <div className="space-y-2">
          <Label htmlFor="password-value">Password</Label>
          <Input
            id="password-value"
            type="password"
            autoComplete="current-password"
            value={passwordForm.data.password}
            onChange={(event) => passwordForm.setData("password", event.target.value)}
          />
          {errors.password && <p className="text-sm text-destructive">{errors.password}</p>}
        </div>

        <div className="flex items-center gap-2">
          <Checkbox
            id="remember-me"
            checked={passwordForm.data.remember_me}
            onCheckedChange={(checked) => passwordForm.setData("remember_me", checked === true)}
            className="focus-visible:border-ring focus-visible:ring-ring/50 size-4 rounded focus-visible:ring-[3px]"
          />
          <Label htmlFor="remember-me">Remember me</Label>
        </div>

        <div>
          <Button type="submit" disabled={passwordForm.processing} className="w-full">
            {passwordForm.processing ? "Logging in..." : "Log in"}
          </Button>
        </div>
      </form>
      <p className="text-sm text-muted-foreground">
        Don&apos;t have an account?{" "}
        <Link
          href="/register"
          className="font-medium text-foreground underline-offset-4 hover:underline"
        >
          Sign up
        </Link>
      </p>
    </>
  );
}

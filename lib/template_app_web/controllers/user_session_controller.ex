defmodule TemplateAppWeb.UserSessionController do
  use TemplateAppWeb, :controller

  alias TemplateApp.Accounts
  alias TemplateApp.Accounts.User
  alias TemplateAppWeb.UserAuth

  def new(conn, params, scope) do
    email =
      case scope do
        %{user: %{email: user_email}} -> user_email
        _ -> nil
      end

    conn
    |> maybe_store_return_to(params)
    |> render_login(email || "")
  end

  # email + password login
  def create(conn, %{"user" => %{"email" => email, "password" => password} = user_params}) do
    case Accounts.get_user_by_email_and_password(email, password) do
      %User{confirmed_at: nil} ->
        conn
        |> put_status(:unprocessable_entity)
        |> assign_errors(%{email: "You must confirm your account before logging in."})
        |> render_login(email)

      %User{} = user ->
        UserAuth.log_in_user(conn, user, user_params)

      nil ->
        # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
        conn
        |> put_status(:unprocessable_entity)
        |> assign_errors(%{email: "Invalid email or password"})
        |> render_login(email)
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end

  defp local_mail_adapter? do
    Application.get_env(:template_app, TemplateApp.Mailer)[:adapter] == Swoosh.Adapters.Local and
      Application.get_env(:template_app, :dev_routes, false)
  end

  defp render_login(conn, email) do
    conn
    |> assign_prop(:form, %{"email" => email})
    |> assign_prop(:local_mail_adapter, local_mail_adapter?())
    |> render_inertia("public/login")
  end

  defp maybe_store_return_to(conn, %{"return_to" => return_to}) when is_binary(return_to) do
    if valid_return_to_path?(return_to) do
      put_session(conn, :user_return_to, return_to)
    else
      conn
    end
  end

  defp maybe_store_return_to(conn, _params), do: conn

  defp valid_return_to_path?(return_to) do
    String.starts_with?(return_to, "/") and not String.starts_with?(return_to, "//")
  end
end

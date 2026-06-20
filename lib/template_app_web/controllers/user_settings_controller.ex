defmodule TemplateAppWeb.UserSettingsController do
  use TemplateAppWeb, :controller

  alias TemplateApp.Accounts
  alias TemplateAppWeb.UserAuth

  def show(conn, _params, scope) do
    conn
    |> assign_prop(:email, scope.user.email)
    |> render_inertia("app/settings/account")
  end

  def update(conn, %{"action" => "update_email"} = params, scope) do
    %{"user" => user_params} = params
    user = scope.user

    case Accounts.change_user_email(user, user_params) do
      %{valid?: true} = changeset ->
        Accounts.deliver_user_update_email_instructions(
          Ecto.Changeset.apply_action!(changeset, :insert),
          user.email,
          &url(~p"/users/settings/confirm-email/#{&1}")
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: ~p"/users/settings")

      changeset ->
        conn
        |> put_status(:unprocessable_entity)
        |> assign_errors(%{changeset | action: :insert})
        |> assign_prop(:email, Ecto.Changeset.get_field(changeset, :email) || user.email)
        |> assign_prop(:active_form, "email")
        |> render_inertia("app/settings/account")
    end
  end

  def update(conn, %{"action" => "update_password"} = params, scope) do
    %{"user" => user_params} = params
    user = scope.user

    case Accounts.update_user_password(user, user_params) do
      {:ok, {user, _}} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:user_return_to, ~p"/users/settings")
        |> UserAuth.log_in_user(user)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> assign_errors(changeset)
        |> assign_prop(:email, user.email)
        |> assign_prop(:active_form, "password")
        |> render_inertia("app/settings/account")
    end
  end

  def confirm_email(conn, %{"token" => token}, scope) do
    case Accounts.update_user_email(scope.user, token) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: ~p"/users/settings")

      {:error, _} ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: ~p"/users/settings")
    end
  end
end

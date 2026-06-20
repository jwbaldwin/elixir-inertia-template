defmodule TemplateAppWeb.UserConfirmationController do
  use TemplateAppWeb, :controller

  alias TemplateApp.Accounts

  def confirm(conn, %{"token" => token}) do
    case Accounts.confirm_user(token) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User confirmed successfully.")
        |> redirect(to: ~p"/login")

      :error ->
        conn
        |> put_flash(:error, "User confirmation link is invalid or it has expired.")
        |> redirect(to: ~p"/login")
    end
  end
end

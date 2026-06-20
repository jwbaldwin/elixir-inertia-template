defmodule TemplateAppWeb.UserConfirmationControllerTest do
  use TemplateAppWeb.ConnCase, async: true

  alias TemplateApp.Accounts

  describe "GET /users/confirm/:token" do
    test "confirms account with valid token", %{conn: conn} do
      user = insert(:unconfirmed_user)

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      conn = get(conn, ~p"/users/confirm/#{token}")

      assert redirected_to(conn) == ~p"/login"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "User confirmed successfully."
      assert Accounts.get_user!(user.id).confirmed_at
    end

    test "emits error with invalid token", %{conn: conn} do
      conn = get(conn, ~p"/users/confirm/invalid-token")

      assert redirected_to(conn) == ~p"/login"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "User confirmation link is invalid or it has expired."
    end

    test "redirects when user is already logged in", %{conn: conn} do
      token = "any-token"

      conn =
        conn
        |> log_in_user(insert(:user))
        |> get(~p"/users/confirm/#{token}")

      assert redirected_to(conn) == ~p"/"
    end
  end
end

defmodule TemplateAppWeb.UserSessionControllerTest do
  use TemplateAppWeb.ConnCase, async: true

  import Inertia.Testing

  setup do
    user = insert(:user)
    insert(:membership, user: user)

    %{unconfirmed_user: insert(:unconfirmed_user), user: user}
  end

  describe "GET /login" do
    test "renders login page", %{conn: conn} do
      conn = get(conn, ~p"/login")

      assert inertia_component(conn) == "public/login"
      assert %{"email" => ""} = inertia_props(conn).form
      assert inertia_props(conn).local_mail_adapter == false
    end

    test "renders login page with email filled in for logged-in users", %{conn: conn, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> get(~p"/login")

      assert inertia_component(conn) == "public/login"
      assert inertia_props(conn).form["email"] == user.email
    end

    test "stores return_to path when provided", %{conn: conn} do
      conn = get(conn, ~p"/login?return_to=/org/invites/some-token")

      assert get_session(conn, :user_return_to) == "/org/invites/some-token"
    end
  end

  describe "POST /login" do
    test "logs the user in", %{conn: conn, user: user} do
      user = set_password(user)

      conn =
        post(conn, ~p"/login", %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == ~p"/"

      conn = get(conn, ~p"/")
      assert inertia_component(conn) == "app/dashboard"
      assert inertia_props(conn).auth.user.email == user.email
    end

    test "logs the user in with remember me", %{conn: conn, user: user} do
      user = set_password(user)

      conn =
        post(conn, ~p"/login", %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password(),
            "remember_me" => true
          }
        })

      assert conn.resp_cookies["_template_app_web_user_remember_me"]
      assert redirected_to(conn) == ~p"/"
    end

    test "logs the user in with return to", %{conn: conn, user: user} do
      user = set_password(user)

      conn =
        conn
        |> init_test_session(user_return_to: "/foo/bar")
        |> post(~p"/login", %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
    end

    test "emits error message with invalid credentials", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/login", %{
          "user" => %{"email" => user.email, "password" => "invalid_password"}
        })

      assert conn.status == 422
      assert inertia_component(conn) == "public/login"
      assert inertia_props(conn).form["email"] == user.email
      assert inertia_errors(conn)[:email] == "Invalid email or password"
    end

    test "blocks login for unconfirmed user", %{conn: conn, unconfirmed_user: user} do
      user = set_password(user)

      conn =
        post(conn, ~p"/login", %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      refute get_session(conn, :user_token)
      assert conn.status == 422
      assert inertia_component(conn) == "public/login"
      assert inertia_props(conn).form["email"] == user.email
      assert inertia_errors(conn)[:email] == "You must confirm your account before logging in."
    end
  end

  describe "DELETE /users/log-out" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> delete(~p"/users/log-out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the user is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/users/log-out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end
end

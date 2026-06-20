defmodule TemplateAppWeb.UserRegistrationControllerTest do
  use TemplateAppWeb.ConnCase, async: true

  import Inertia.Testing

  alias TemplateApp.Accounts
  alias TemplateApp.Accounts.UserToken

  describe "GET /register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, ~p"/register")

      assert inertia_component(conn) == "public/register"

      assert %{
               "name" => "",
               "email" => "",
               "company_name" => "",
               "password" => "",
               "password_confirmation" => ""
             } = inertia_props(conn).form
    end

    test "redirects if already logged in", %{conn: conn} do
      conn = conn |> log_in_user(insert(:user)) |> get(~p"/register")

      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "POST /register" do
    @tag :capture_log
    test "creates account but does not log in", %{conn: conn} do
      registration_attrs = string_params_for(:registration_attrs)

      conn =
        post(conn, ~p"/register", %{
          "user" => registration_attrs
        })

      refute get_session(conn, :user_token)
      assert redirected_to(conn) == ~p"/login"

      user = Accounts.get_user_by_email(registration_attrs["email"])
      assert %UserToken{context: "confirm"} = TemplateApp.Repo.get_by!(UserToken, user_id: user.id)

      assert conn.assigns.flash["info"] =~
               ~r/An email was sent to .*, please use the link to confirm your account/
    end

    test "render errors for invalid data", %{conn: conn} do
      invalid_attrs = string_params_for(:registration_attrs, email: "with spaces")
      expected_name = invalid_attrs["name"]
      expected_company_name = invalid_attrs["company_name"]

      conn =
        post(conn, ~p"/register", %{
          "user" => invalid_attrs
        })

      assert conn.status == 422
      assert inertia_component(conn) == "public/register"

      assert %{
               "name" => ^expected_name,
               "email" => "with spaces",
               "company_name" => ^expected_company_name,
               "password" => "",
               "password_confirmation" => ""
             } = inertia_props(conn).form

      assert inertia_errors(conn)[:email] == "must have the @ sign and no spaces"
    end

    test "renders errors for invalid password", %{conn: conn} do
      invalid_attrs =
        string_params_for(
          :registration_attrs,
          password: "short",
          password_confirmation: "short"
        )

      conn =
        post(conn, ~p"/register", %{
          "user" => invalid_attrs
        })

      assert conn.status == 422
      assert inertia_component(conn) == "public/register"
      assert inertia_errors(conn)[:password] == "should be at least 12 character(s)"
      assert inertia_props(conn).form["password"] == ""
      assert inertia_props(conn).form["password_confirmation"] == ""
    end

    test "renders errors for invalid company name", %{conn: conn} do
      invalid_attrs = string_params_for(:registration_attrs, company_name: "   ")

      conn =
        post(conn, ~p"/register", %{
          "user" => invalid_attrs
        })

      assert conn.status == 422
      assert inertia_component(conn) == "public/register"
      assert inertia_errors(conn)[:company_name] == "can't be blank"
    end

    test "shows invite guidance when company already exists", %{conn: conn} do
      _organization = insert(:organization, name: "Acme Studio", slug: "acme-studio")

      registration_attrs =
        string_params_for(:registration_attrs, company_name: "Acme Studio")

      conn =
        post(conn, ~p"/register", %{
          "user" => registration_attrs
        })

      assert conn.status == 422
      assert inertia_component(conn) == "public/register"

      assert inertia_errors(conn)[:company_name] ==
               "That company already exists. Ask an organization admin to invite you."

      assert inertia_props(conn).form["company_name"] == "Acme Studio"
      refute Accounts.get_user_by_email(registration_attrs["email"])
    end
  end
end

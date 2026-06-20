defmodule TemplateAppWeb.CurrentOrganizationControllerTest do
  use TemplateAppWeb.ConnCase, async: true

  @active_organization_cookie "_template_app_web_active_organization_id"

  describe "PUT /org/current" do
    test "updates the active organization when the user is a member", %{conn: conn} do
      user = insert(:user)
      current_organization = insert(:organization, name: "Current Studio")
      target_organization = insert(:organization, name: "Target Studio")

      insert(:membership, user: user, organization: current_organization)
      insert(:membership, user: user, organization: target_organization)

      conn =
        conn
        |> log_in_user(user)
        |> put_session(:active_organization_id, current_organization.id)
        |> put(~p"/org/current", %{"organization_id" => Integer.to_string(target_organization.id)})

      assert redirected_to(conn) == ~p"/"
      assert get_session(conn, :active_organization_id) == target_organization.id
      assert %{value: signed_active_organization_id} = conn.resp_cookies[@active_organization_cookie]
      assert signed_active_organization_id != Integer.to_string(target_organization.id)
    end

    test "rejects organizations the user is not a member of", %{conn: conn} do
      user = insert(:user)
      current_organization = insert(:organization)
      unrelated_organization = insert(:organization)

      insert(:membership, user: user, organization: current_organization)

      conn =
        conn
        |> log_in_user(user)
        |> put_session(:active_organization_id, current_organization.id)
        |> put(~p"/org/current", %{"organization_id" => Integer.to_string(unrelated_organization.id)})

      assert redirected_to(conn) == ~p"/"
      assert get_session(conn, :active_organization_id) == current_organization.id
      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Organization not found"
    end

    test "rejects invalid organization ids", %{conn: conn} do
      user = insert(:user)
      current_organization = insert(:organization)

      insert(:membership, user: user, organization: current_organization)

      conn =
        conn
        |> log_in_user(user)
        |> put_session(:active_organization_id, current_organization.id)
        |> put(~p"/org/current", %{"organization_id" => "not-an-id"})

      assert redirected_to(conn) == ~p"/"
      assert get_session(conn, :active_organization_id) == current_organization.id
      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Organization not found"
    end
  end
end

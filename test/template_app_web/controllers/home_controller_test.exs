defmodule TemplateAppWeb.HomeControllerTest do
  use TemplateAppWeb.ConnCase, async: true

  import Inertia.Testing

  test "GET / renders dashboard for authenticated users", %{conn: conn} do
    user = insert(:user)
    organization = insert(:organization)

    insert(:membership, user: user, organization: organization, role: :admin)

    conn =
      conn
      |> log_in_user(user)
      |> put_session(:active_organization_id, organization.id)
      |> get(~p"/")

    assert inertia_component(conn) == "app/dashboard"

    props = inertia_props(conn)

    assert props.organization_name == organization.name
  end
end

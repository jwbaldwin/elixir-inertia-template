defmodule TemplateAppWeb.CurrentOrganizationController do
  use TemplateAppWeb, :controller

  alias TemplateApp.Organizations
  alias TemplateAppWeb.UserAuth

  def update(conn, %{"organization_id" => organization_id}, scope) do
    with {parsed_organization_id, ""} <- Integer.parse(organization_id),
         {:ok, organization} <- Organizations.fetch_active_organization_by_user(scope.user, parsed_organization_id) do
      conn
      |> UserAuth.put_active_organization(organization)
      |> redirect(to: ~p"/")
    else
      _ ->
        conn
        |> put_flash(:error, "Organization not found")
        |> redirect(to: ~p"/")
    end
  end
end

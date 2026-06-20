defmodule TemplateAppWeb.HomeController do
  use TemplateAppWeb, :controller

  def index(conn, _params, scope) do
    conn
    |> assign(:page_title, "Dashboard")
    |> assign_prop(:organization_name, scope.organization && scope.organization.name)
    |> render_inertia("app/dashboard")
  end
end

defmodule TemplateAppWeb.OrganizationSettingsController do
  use TemplateAppWeb, :controller

  alias TemplateApp.Authorization
  alias TemplateApp.Organizations.Handlers.OrganizationSettings

  action_fallback TemplateAppWeb.FallbackController

  @settings_path "/org/settings"

  def show(conn, _params, scope) do
    with :ok <- Authorization.permit(scope, :can_view),
         {:ok, settings} <- OrganizationSettings.load_settings(scope) do
      render_settings(conn, settings, Authorization.can_edit?(scope))
    end
  end

  def update(conn, %{"organization" => %{"name" => name}}, scope) do
    with :ok <- Authorization.permit(scope, :can_edit),
         {:ok, _organization} <- OrganizationSettings.update_organization_name(scope, %{"name" => name}) do
      conn
      |> put_flash(:info, "Organization updated")
      |> redirect(to: @settings_path)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render_invalid_settings(conn, scope, changeset)

      error ->
        error
    end
  end

  defp render_invalid_settings(conn, scope, errors) do
    with {:ok, settings} <- OrganizationSettings.load_settings(scope) do
      conn
      |> put_status(:unprocessable_entity)
      |> assign_errors(errors)
      |> render_settings(settings, Authorization.can_edit?(scope))
    end
  end

  defp render_settings(
         conn,
         %{organization: organization, invitations: invitations, members: members, form: form},
         can_edit
       ) do
    conn
    |> assign_prop(:organization, organization)
    |> assign_prop(:invitations, invitations)
    |> assign_prop(:members, members)
    |> assign_prop(:can_edit, can_edit)
    |> assign_prop(:form, form)
    |> render_inertia("app/settings/organization")
  end
end

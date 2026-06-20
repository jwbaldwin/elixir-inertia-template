defmodule TemplateAppWeb.OrganizationInvitationsController do
  @moduledoc """
  Controller for managing organization invitations settings page data, does not handle the
  actual acceptance of invitations, that is in `TemplateAppWeb.OrganizationInvitationController`
  """
  use TemplateAppWeb, :controller

  alias TemplateApp.Authorization
  alias TemplateApp.Organizations.Handlers.OrganizationSettings

  action_fallback TemplateAppWeb.FallbackController

  @settings_path "/org/settings"

  def create(conn, %{"invitation" => invitation_params}, scope) do
    with :ok <- Authorization.permit(scope, :can_edit),
         {:ok, _invitation} <-
           OrganizationSettings.create_invitation(
             scope,
             invitation_params,
             &url(~p"/org/invites/#{&1}")
           ) do
      conn
      |> put_flash(:info, "Invitation sent")
      |> redirect(to: @settings_path)
    else
      {:error, :already_member} ->
        render_invalid_invitation(conn, scope, invitation_params, %{
          email: "That user is already a member of this organization."
        })

      {:error, :invalid_email} ->
        render_invalid_invitation(conn, scope, invitation_params, %{email: "can't be blank"})

      {:error, %Ecto.Changeset{} = changeset} ->
        render_invalid_invitation(conn, scope, invitation_params, changeset)

      error ->
        error
    end
  end

  def delete(conn, %{"invitation_id" => invitation_id}, scope) do
    with :ok <- Authorization.permit(scope, :can_edit),
         {:ok, _invitation} <- OrganizationSettings.cancel_invitation(scope, invitation_id) do
      conn
      |> put_flash(:info, "Invitation cancelled")
      |> redirect(to: @settings_path)
    else
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Invitation not found")
        |> redirect(to: @settings_path)

      error ->
        error
    end
  end

  defp render_invalid_invitation(conn, scope, invitation_params, errors) do
    with {:ok, settings} <- OrganizationSettings.load_settings(scope, invitation_params) do
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

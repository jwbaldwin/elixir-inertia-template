defmodule TemplateAppWeb.OrganizationMembersController do
  use TemplateAppWeb, :controller

  alias TemplateApp.Authorization
  alias TemplateApp.Organizations.Handlers.OrganizationSettings

  action_fallback TemplateAppWeb.FallbackController

  @settings_path "/org/settings"

  def delete(conn, %{"membership_id" => membership_id}, scope) do
    with {:ok, parsed_membership_id} <- parse_membership_id(membership_id),
         :ok <- Authorization.permit(scope, :can_edit),
         {:ok, _membership} <- OrganizationSettings.remove_member(scope, parsed_membership_id) do
      conn
      |> put_flash(:info, "Member removed")
      |> redirect(to: @settings_path)
    else
      {:error, :cannot_remove_self} ->
        conn
        |> put_flash(:error, "You cannot remove yourself from this organization.")
        |> redirect(to: @settings_path)

      {:error, :member_not_found} ->
        conn
        |> put_flash(:error, "Member not found")
        |> redirect(to: @settings_path)

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Member not found")
        |> redirect(to: @settings_path)

      error ->
        error
    end
  end

  defp parse_membership_id(membership_id) do
    case Integer.parse(membership_id) do
      {parsed_membership_id, ""} -> {:ok, parsed_membership_id}
      _ -> {:error, :member_not_found}
    end
  end
end

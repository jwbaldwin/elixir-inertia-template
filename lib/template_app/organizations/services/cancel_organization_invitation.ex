defmodule TemplateApp.Organizations.Services.CancelOrganizationInvitation do
  @moduledoc """
  Cancels a pending invitation
  """

  alias TemplateApp.Invitations
  alias TemplateApp.Invitations.Invitation

  @doc """
  Cancels a pending invitation
  """
  @spec call(Invitation.t()) :: {:ok, map()} | {:error, term()}
  def call(invitation) when is_map(invitation) do
    Invitations.update_organization_invitation_status(invitation, :cancelled)
  end

  def call(_invitation), do: {:error, :not_found}
end

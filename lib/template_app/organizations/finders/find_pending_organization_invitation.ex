defmodule TemplateApp.Organizations.Finders.FindPendingOrganizationInvitation do
  @moduledoc """
  Finds a pending invitation by organization and invitation id
  """

  import Ecto.Query, warn: false

  alias TemplateApp.Accounts.Invitation
  alias TemplateApp.Repo

  @doc @moduledoc
  @spec find(map()) :: {:ok, map()} | {:error, :not_found}
  def find(%{organization_id: organization_id, invitation_id: invitation_id})
      when is_integer(organization_id) and is_integer(invitation_id) do
    from(invitation in Invitation,
      where:
        invitation.organization_id == ^organization_id and
          invitation.id == ^invitation_id and
          invitation.status == :pending,
      preload: [:organization, :inviter]
    )
    |> Repo.one()
    |> Repo.normalize_one()
  end

  def find(_params), do: {:error, :not_found}
end

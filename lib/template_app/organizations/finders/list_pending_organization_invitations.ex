defmodule TemplateApp.Organizations.Finders.ListPendingOrganizationInvitations do
  @moduledoc """
  Lists pending invitations for an organization
  """

  import Ecto.Query, warn: false

  alias TemplateApp.Accounts.Invitation
  alias TemplateApp.Repo

  @doc @moduledoc
  @spec find(map()) :: [map()] | []
  def find(%{organization_id: organization_id}) when is_integer(organization_id) do
    Repo.all(
      from(invitation in Invitation,
        where: invitation.organization_id == ^organization_id and invitation.status == :pending,
        order_by: [desc: invitation.inserted_at],
        preload: [:inviter]
      )
    )
  end

  def find(_), do: []
end

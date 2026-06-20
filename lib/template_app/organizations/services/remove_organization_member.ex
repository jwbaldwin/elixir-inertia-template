defmodule TemplateApp.Organizations.Services.RemoveOrganizationMember do
  @moduledoc """
  Removes a member from the active organization
  """

  alias TemplateApp.Accounts.Membership
  alias TemplateApp.Accounts.Scope
  alias TemplateApp.Memberships

  @doc """
  Removes a member from the active organization
  """
  @spec call(Scope.t(), integer()) :: {:ok, Membership.t()} | {:error, term()}
  def call(%Scope{organization: %{id: org_id}, user: %{id: user_id}}, membership_id) do
    with {:ok, membership} <- Memberships.find_membership_by(%{org_id: org_id, membership_id: membership_id}),
         :ok <- ensure_not_self(membership, user_id) do
      Memberships.delete_membership(membership)
    end
  end

  defp ensure_not_self(membership, user_id) do
    if membership.user_id == user_id do
      {:error, :cannot_remove_self}
    else
      :ok
    end
  end
end

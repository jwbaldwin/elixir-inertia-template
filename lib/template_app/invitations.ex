defmodule TemplateApp.Invitations do
  @moduledoc """
  Invitation CRUD and query operations
  """

  import Ecto.Query, warn: false

  alias TemplateApp.Accounts.Invitation
  alias TemplateApp.Organizations.Finders.FindOrganizationInvitationByToken
  alias TemplateApp.Organizations.Finders.FindPendingOrganizationInvitation
  alias TemplateApp.Organizations.Finders.ListPendingOrganizationInvitations
  alias TemplateApp.Repo

  @doc """
  Lists pending invitations for an organization
  """
  @spec list_pending_organization_invitations(integer()) :: [map()]
  def list_pending_organization_invitations(organization_id) when is_integer(organization_id) do
    ListPendingOrganizationInvitations.find(%{organization_id: organization_id})
  end

  def list_pending_organization_invitations(_organization_id), do: []

  @doc """
  Finds an invitation by token
  """
  @spec find_organization_invitation_by_token(String.t()) :: {:ok, map()} | {:error, :not_found}
  def find_organization_invitation_by_token(token) when is_binary(token) do
    FindOrganizationInvitationByToken.find(token)
  end

  def find_organization_invitation_by_token(_token), do: {:error, :not_found}

  @doc """
  Finds a pending invitation in an organization by id
  """
  @spec find_pending_organization_invitation(integer(), integer() | String.t()) ::
          {:ok, map()} | {:error, :not_found}
  def find_pending_organization_invitation(organization_id, invitation_id) when is_integer(organization_id) do
    case parse_invitation_id(invitation_id) do
      nil ->
        {:error, :not_found}

      parsed_invitation_id ->
        FindPendingOrganizationInvitation.find(%{
          organization_id: organization_id,
          invitation_id: parsed_invitation_id
        })
    end
  end

  def find_pending_organization_invitation(_organization_id, _invitation_id), do: {:error, :not_found}

  @doc """
  Creates an invitation
  """
  @spec create_organization_invitation(map()) :: {:ok, map()} | {:error, Ecto.Changeset.t()}
  def create_organization_invitation(attrs) when is_map(attrs) do
    %Invitation{}
    |> Invitation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates invitation status
  """
  @spec update_organization_invitation_status(map(), atom()) ::
          {:ok, map()} | {:error, Ecto.Changeset.t()}
  def update_organization_invitation_status(invitation, status) when is_map(invitation) and is_atom(status) do
    invitation
    |> Invitation.changeset(%{status: status})
    |> Repo.update()
  end

  @doc """
  Cancels pending invitations for organization and email
  """
  @spec cancel_pending_organization_invitations(integer(), String.t()) :: :ok
  def cancel_pending_organization_invitations(organization_id, email)
      when is_integer(organization_id) and is_binary(email) do
    now = DateTime.utc_now(:second)
    normalized_email = email |> String.trim() |> String.downcase()

    Repo.update_all(
      from(invitation in Invitation,
        where:
          invitation.organization_id == ^organization_id and
            invitation.email == ^normalized_email and
            invitation.status == :pending
      ),
      set: [status: :cancelled, updated_at: now]
    )

    :ok
  end

  def cancel_pending_organization_invitations(_organization_id, _email), do: :ok

  defp parse_invitation_id(value) when is_integer(value), do: value

  defp parse_invitation_id(value) when is_binary(value) do
    case Integer.parse(value) do
      {invitation_id, ""} -> invitation_id
      _ -> nil
    end
  end

  defp parse_invitation_id(_value), do: nil
end

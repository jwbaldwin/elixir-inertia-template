defmodule TemplateApp.Memberships do
  @moduledoc """
  Membership helpers and queries
  """

  import Ecto.Query, warn: false

  alias TemplateApp.Accounts.Membership
  alias TemplateApp.Repo

  def roles, do: Membership.roles()
  def owner_role, do: :owner

  @doc """
  Finds a membership by lookup attrs

  Supports:
  - %{org_id: integer(), user_id: integer()}
  - %{org_id: integer(), membership_id: integer()}
  """
  @spec find_membership_by(%{org_id: integer(), user_id: integer()} | %{org_id: integer(), membership_id: integer()}) ::
          {:ok, Membership.t()} | {:error, :not_found}
  def find_membership_by(%{org_id: organization_id, user_id: user_id}) do
    from(membership in Membership,
      where:
        membership.organization_id == ^organization_id and
          membership.user_id == ^user_id
    )
    |> Repo.one()
    |> Repo.normalize_one()
  end

  def find_membership_by(%{org_id: organization_id, membership_id: membership_id}) do
    from(membership in Membership,
      where:
        membership.organization_id == ^organization_id and
          membership.id == ^membership_id
    )
    |> Repo.one()
    |> Repo.normalize_one()
  end

  @doc """
  Returns whether a user with the given email is already a member of the organization
  """
  @spec member_exists_for_email?(integer(), String.t()) :: boolean()
  def member_exists_for_email?(organization_id, email) when is_integer(organization_id) and is_binary(email) do
    normalized_email = email |> String.trim() |> String.downcase()

    from(membership in Membership,
      join: member_user in assoc(membership, :user),
      where:
        membership.organization_id == ^organization_id and
          member_user.email == ^normalized_email,
      select: membership.id,
      limit: 1
    )
    |> Repo.one()
    |> is_integer()
  end

  def member_exists_for_email?(_organization_id, _email), do: false

  @doc """
  Ensures a membership exists and returns it
  """
  @spec ensure_membership(integer(), integer(), atom()) ::
          {:ok, Membership.t()} | {:error, Ecto.Changeset.t() | :invalid_role}
  def ensure_membership(organization_id, user_id, role)
      when is_integer(organization_id) and is_integer(user_id) and role in [:owner, :admin, :member] do
    case find_membership_by(%{org_id: organization_id, user_id: user_id}) do
      {:ok, membership} ->
        {:ok, membership}

      {:error, :not_found} ->
        %Membership{}
        |> Membership.changeset(%{organization_id: organization_id, user_id: user_id, role: role})
        |> Repo.insert()
    end
  end

  def ensure_membership(_organization_id, _user_id, _role), do: {:error, :invalid_role}

  @doc """
  Deletes a membership
  """
  @spec delete_membership(Membership.t()) :: {:ok, Membership.t()} | {:error, Ecto.Changeset.t()}
  def delete_membership(%Membership{} = membership), do: Repo.delete(membership)

  @doc """
  Lists organization members with user data preloaded
  """
  @spec list_organization_members(integer()) :: [Membership.t()]
  def list_organization_members(organization_id) when is_integer(organization_id) do
    Repo.all(
      from(membership in Membership,
        join: member_user in assoc(membership, :user),
        where: membership.organization_id == ^organization_id,
        order_by: [asc: member_user.name, asc: member_user.email],
        preload: [user: member_user]
      )
    )
  end

  def list_organization_members(_organization_id), do: []
end

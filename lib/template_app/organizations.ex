defmodule TemplateApp.Organizations do
  @moduledoc """
  The organizations context
  """

  import Ecto.Query, warn: false

  alias TemplateApp.Accounts.Organization
  alias TemplateApp.Accounts.User
  alias TemplateApp.Organizations.Services.SlugifyOrganizationName
  alias TemplateApp.Repo

  @doc """
  Lists organizations
  """
  @spec list_organizations() :: [Organization.t()]
  def list_organizations do
    Repo.all(from organization in Organization, order_by: [asc: organization.name])
  end

  @doc """
  Gets a single organization
  """
  @spec get_organization(integer()) :: {:ok, Organization.t()} | {:error, :not_found}
  def get_organization(id) when is_integer(id) do
    Organization
    |> Repo.get(id)
    |> Repo.normalize_one()
  end

  def get_organization(_), do: {:error, :not_found}

  @doc """
  Finds an organization by slug
  """
  @spec find_organization_by_slug(String.t()) :: {:ok, Organization.t()} | {:error, :not_found}
  def find_organization_by_slug(slug) do
    from(organization in Organization, where: organization.slug == ^slug)
    |> Repo.one()
    |> Repo.normalize_one()
  end

  @doc """
  Creates an organization
  """
  @spec create_organization(map()) :: {:ok, Organization.t()} | {:error, Ecto.Changeset.t()}
  def create_organization(attrs) when is_map(attrs) do
    %Organization{}
    |> Organization.changeset(build_organization_attrs(attrs))
    |> Repo.insert()
  end

  @doc """
  Updates an organization
  """
  @spec update_organization(Organization.t(), map()) ::
          {:ok, Organization.t()} | {:error, Ecto.Changeset.t()}
  def update_organization(%Organization{} = organization, attrs) when is_map(attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an organization
  """
  @spec delete_organization(Organization.t()) :: {:ok, Organization.t()} | {:error, Ecto.Changeset.t()}
  def delete_organization(%Organization{} = organization), do: Repo.delete(organization)

  @doc """
  Returns the user's active organization from a preferred organization id
  """
  @spec fetch_active_organization_by_user(User.t(), integer() | nil) ::
          {:ok, Organization.t()} | {:error, :not_found}
  def fetch_active_organization_by_user(user, preferred_organization_id \\ nil)

  def fetch_active_organization_by_user(%User{id: user_id}, preferred_organization_id)
      when is_integer(preferred_organization_id) do
    user_id
    |> active_organization_query(preferred_organization_id)
    |> Repo.one()
    |> Repo.normalize_one()
  end

  def fetch_active_organization_by_user(%User{}, _preferred_organization_id), do: {:error, :not_found}

  @doc """
  Returns the first organization found for a user
  """
  @spec fetch_first_organization_by_user(User.t()) :: {:ok, Organization.t()} | {:error, :not_found}
  def fetch_first_organization_by_user(%User{id: user_id}) do
    organization_query = organizations_by_user_query(user_id)

    from(organization in organization_query, limit: 1)
    |> Repo.one()
    |> Repo.normalize_one()
  end

  def fetch_first_organization_by_user(%User{}), do: {:error, :not_found}

  @doc """
  Lists organizations the user belongs to
  """
  @spec list_organizations_by_user(User.t()) :: [Organization.t()]
  def list_organizations_by_user(%User{id: user_id}) do
    user_id
    |> organizations_by_user_query()
    |> Repo.all()
  end

  def list_organizations_by_user(%User{}), do: []

  defp active_organization_query(user_id, organization_id) do
    from organization in Organization,
      join: membership in assoc(organization, :memberships),
      where:
        membership.user_id == ^user_id and
          membership.organization_id == ^organization_id,
      limit: 1,
      select: organization
  end

  defp organizations_by_user_query(user_id) do
    from organization in Organization,
      join: membership in assoc(organization, :memberships),
      where: membership.user_id == ^user_id,
      order_by: [asc: organization.name, asc: organization.id],
      select: organization
  end

  defp build_organization_attrs(attrs) do
    name = Map.get(attrs, :name) || Map.get(attrs, "name")

    %{
      name: name,
      slug: Map.get(attrs, :slug) || Map.get(attrs, "slug") || SlugifyOrganizationName.call(name)
    }
  end
end

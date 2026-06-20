defmodule TemplateApp.Accounts.Membership do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @roles [:owner, :admin, :member]
  @manager_roles [:owner, :admin]

  schema "memberships" do
    field :role, Ecto.Enum, values: @roles

    belongs_to :organization, TemplateApp.Accounts.Organization
    belongs_to :user, TemplateApp.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:organization_id, :user_id, :role])
    |> validate_required([:organization_id, :user_id, :role])
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint([:organization_id, :user_id])
    |> check_constraint(:role, name: :memberships_role_check)
  end

  def roles, do: @roles
  def manager_roles, do: @manager_roles
  def manager_role?(role) when is_atom(role), do: role in @manager_roles
  def manager_role?(_role), do: false
end

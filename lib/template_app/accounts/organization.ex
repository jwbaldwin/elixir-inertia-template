defmodule TemplateApp.Accounts.Organization do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  schema "organizations" do
    field :name, :string
    field :slug, :string

    has_many :memberships, TemplateApp.Accounts.Membership
    has_many :invitations, TemplateApp.Accounts.Invitation

    timestamps(type: :utc_datetime)
  end

  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
    |> validate_length(:name, min: 1, max: 160)
    |> validate_length(:slug, min: 1, max: 120)
    |> unique_constraint(:slug)
  end
end

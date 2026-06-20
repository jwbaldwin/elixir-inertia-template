defmodule TemplateApp.Accounts.Invitation do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @roles TemplateApp.Accounts.Membership.roles()
  @invite_statuses [:pending, :accepted, :rejected, :cancelled]

  schema "invitations" do
    field :email, :string
    field :role, Ecto.Enum, values: @roles
    field :status, Ecto.Enum, values: @invite_statuses, default: :pending
    field :token_hash, :binary
    field :expires_at, :utc_datetime

    belongs_to :organization, TemplateApp.Accounts.Organization
    belongs_to :inviter, TemplateApp.Accounts.User, foreign_key: :inviter_user_id

    timestamps(type: :utc_datetime)
  end

  def invite_statuses, do: @invite_statuses

  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [
      :organization_id,
      :email,
      :role,
      :inviter_user_id,
      :status,
      :token_hash,
      :expires_at
    ])
    |> validate_required([
      :organization_id,
      :email,
      :role,
      :inviter_user_id,
      :status,
      :token_hash,
      :expires_at
    ])
    |> update_change(:email, &normalize_email/1)
    |> validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:inviter_user_id)
    |> unique_constraint(:token_hash)
    |> check_constraint(:role, name: :invitations_role_check)
    |> check_constraint(:status, name: :invitations_status_check)
  end

  defp normalize_email(value) when is_binary(value), do: value |> String.trim() |> String.downcase()
  defp normalize_email(value), do: value
end

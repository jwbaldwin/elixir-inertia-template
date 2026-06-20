defmodule TemplateApp.Repo.Migrations.CreateInvitations do
  use Ecto.Migration

  def change do
    create table(:invitations) do
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false
      add :email, :citext, null: false
      add :role, :string, null: false
      add :inviter_user_id, references(:users, on_delete: :delete_all), null: false
      add :status, :string, null: false, default: "pending"
      add :token_hash, :binary, null: false
      add :expires_at, :utc_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:invitations, [:organization_id, :status])
    create index(:invitations, [:email, :status])
    create unique_index(:invitations, [:token_hash])

    create constraint(:invitations, :invitations_role_check,
             check: "role IN ('owner', 'admin', 'member')"
           )

    create constraint(:invitations, :invitations_status_check,
             check: "status IN ('pending', 'accepted', 'rejected', 'cancelled')"
           )
  end
end

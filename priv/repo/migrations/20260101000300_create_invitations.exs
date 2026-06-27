defmodule TemplateApp.Repo.Migrations.CreateInvitations do
  use Ecto.Migration

  # The table is created empty here; indexes, references, and checks validate no existing rows.
  # excellent_migrations:safety-assured-for-this-file index_not_concurrently
  # excellent_migrations:safety-assured-for-this-file column_reference_added
  # excellent_migrations:safety-assured-for-this-file check_constraint_added

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

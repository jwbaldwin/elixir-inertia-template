defmodule TemplateApp.Repo.Migrations.CreateMemberships do
  use Ecto.Migration

  # The table is created empty here; indexes, references, and checks validate no existing rows.
  # excellent_migrations:safety-assured-for-this-file index_not_concurrently
  # excellent_migrations:safety-assured-for-this-file column_reference_added
  # excellent_migrations:safety-assured-for-this-file check_constraint_added

  def change do
    create table(:memberships) do
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :role, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:memberships, [:organization_id, :user_id])
    create index(:memberships, [:user_id])

    create constraint(:memberships, :memberships_role_check,
             check: "role IN ('owner', 'admin', 'member')"
           )
  end
end

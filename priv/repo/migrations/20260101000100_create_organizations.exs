defmodule TemplateApp.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  # The table is created empty here, so its index cannot block existing writes.
  # excellent_migrations:safety-assured-for-this-file index_not_concurrently

  def change do
    create table(:organizations) do
      add :name, :string, null: false
      add :slug, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:organizations, [:slug])
  end
end

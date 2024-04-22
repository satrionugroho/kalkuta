defmodule Vienna.Repo.Migrations.CreateTagsTable do
  use Ecto.Migration

  def change do
    create table(:tags, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :color, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:tags, [:name])
  end
end

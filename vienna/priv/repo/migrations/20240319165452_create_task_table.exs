defmodule Vienna.Repo.Migrations.CreateTaskTable do
  use Ecto.Migration

  def change do
    create table(:tasks, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, :uuid, null: false
      add :name, :string, null: false
      add :description, :binary
      add :type, :integer, default: 1
      add :ancestor_id, :uuid
      add :deadline, :utc_datetime
      add :resolved_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:tasks, [:user_id])
    create index(:tasks, [:ancestor_id])
    create index(:tasks, [:name])
  end
end

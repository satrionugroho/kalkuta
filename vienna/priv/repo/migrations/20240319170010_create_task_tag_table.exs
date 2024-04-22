defmodule Vienna.Repo.Migrations.CreateTaskTagTable do
  use Ecto.Migration

  def change do
    create table(:task_tags, primary_key: false) do
      add :task_id, references(:tasks, type: :uuid)
      add :tag_id, references(:tags, type: :uuid)
    end

    create unique_index(:task_tags, [:task_id, :tag_id])
  end
end

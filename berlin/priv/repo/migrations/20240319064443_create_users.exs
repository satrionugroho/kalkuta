defmodule Berlin.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :string
      add :username, :string
      add :password_digest, :binary

      add :last_login_at, :utc_datetime
      add :last_login_ip, :inet
      add :login_count, :integer

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:username])
    create unique_index(:users, [:username, :email])
  end
end

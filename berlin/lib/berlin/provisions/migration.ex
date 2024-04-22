defmodule Berlin.Provisions.Migration do
  alias Berlin.Repo

  @spec ready() :: :ok | {:error, binary()}
  def ready do
    case Repo.__adapter__.storage_up(Repo.config) do
      :ok -> :ok
      {:error, :already_up} -> :ok
      {:error, term} -> {:error, term}
    end
  end

  @spec pending_migrations() :: :already_up | [integer()]
  def pending_migrations do
    Ecto.Migrator.migrations(Repo)
    |> Enum.filter(fn r ->
      elem(r, 0)
      |> Kernel.==(:down)
    end)
  end

  @spec succeed_migrations() :: :already_up | [integer()]
  def succeed_migrations do
    Ecto.Migrator.migrations(Repo)
    |> Enum.filter(fn r ->
      elem(r, 0)
      |> Kernel.==(:up)
    end)
  end

  @spec migrate() :: :already_up | [integer()]
  def migrate do
    case pending_migrations() do
      [] ->
        :logger.info("database ready to use")
        :already_up
      _ ->
        :logger.info("database need provisions and performing pending migrations")
        result = Ecto.Migrator.run(Repo, migration_path(), :up, [all: true])
        :logger.info("migrations performed and have performed migrations with revisions #{inspect result}.")
        result
    end
  end

  defp migration_path do
    :code.priv_dir(:berlin)
    |> Kernel.to_string()
    |> Kernel.<>("/repo/migrations")
  end
end

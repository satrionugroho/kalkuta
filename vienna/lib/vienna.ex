defmodule Vienna do
  use Bakeware.Script
  @moduledoc """
  Documentation for `Vienna`.
  """
  @impl Bakeware.Script
  def main(args) do
    {main, types, _options} =
      args
      |> OptionParser.parse(
        strict: [file: :string, step: :integer, force: :boolean],
        aliases: [f: :file, s: :step]
      )

    _ = configure_environment!()
    {:ok, _} = Vienna.Repo.start_link()

    case List.first(types) do
      "up" -> migrate_up(main)
      "down" -> migrate_down(main)
      cmd -> :logger.notice("command #{inspect cmd} not supported")
    end

    :ok
  end

  defp migrate_up(opts) do
    :logger.notice("Migrate database")
    path = decide_migration_path(opts)
    :logger.notice("migrate database at #{inspect path}")

    case File.exists?(path) do
      true ->
        :logger.notice("running migration")
        try do
          Ecto.Migrator.run(Vienna.Repo, path, :up, [all: true])
        rescue
          err -> :logger.warning("error occured, message #{inspect err}")
        end
        :logger.notice("migration done")
      _ ->
        :logger.notice("migrations file not present at #{inspect path}")
    end
  end

  defp migrate_down(opts) do
    :logger.notice("Rollback database")
    path = decide_migration_path(opts)
    step = decide_migration_step(opts)
    :logger.notice("rollback database at #{inspect path} with step=#{inspect step}")

    case File.exists?(path) do
      true -> 
        :logger.notice("running rollback")
        try do
          Ecto.Migrator.run(Vienna.Repo, path, :down, [step: step])
        rescue
          err -> :logger.warning("error occured, message #{inspect err}")
        end
        :logger.notice("rollback done")
      _ ->
        :logger.notice("migrations file not present at #{inspect path}")
    end
  end

  defp decide_migration_path(opts) do
    Keyword.get(opts, :file)
    |> case do
      nil -> default_migration_path()
      file -> file |> Path.absname()
    end
  end

  defp decide_migration_step(opts) do
    Keyword.get(opts, :step)
    |> case do
      nil -> 1
      number -> number
    end
  end

  defp default_migration_path() do
    :code.priv_dir(:vienna)
    |> Kernel.to_string()
    |> Path.basename()
    |> Path.absname()
    |> Kernel.<>("/repo/migrations")
    |> tap(fn f -> :logger.notice("using default migration file at #{inspect f}") end)
  end

  defp configure_environment! do
    env = 
      Application.get_env(:vienna, Vienna.Repo)
      |> Enum.map(fn {k, v} -> {k, eval_value(v)} end)
    Application.put_env(:vienna, Vienna.Repo, env, persistent: true)
  end

  defp eval_value({mod, fun, args}), do: apply(mod, fun ,args)
  defp eval_value("$" <> name), do: System.get_env(name, nil)
  defp eval_value(value), do: value
end

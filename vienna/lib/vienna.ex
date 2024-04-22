defmodule Vienna do
  use Bakeware.Script

  require Logger

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
    case Vienna.Repo.start_link() do
      {:ok, _} -> Logger.info("connected to database")
      err -> Logger.error("cannot connect to database with error #{inspect err}")
    end

    case List.first(types) do
      "up" -> migrate_up(main)
      "down" -> migrate_down(main)
      nil -> Logger.alert("must specify the command `up` or `down`")
      cmd -> 
        Logger.info("command #{inspect cmd} not supported")
    end

    :ok
  end

  defp migrate_up(opts) do
    Logger.info("Migrate database")
    {ch, path} = decide_migration_path(opts)
    Logger.info("migrate database at #{inspect path}")

    case File.exists?(path) && ch == :ok do
      true ->
        Logger.info("running migration")
        try do
          Ecto.Migrator.run(Vienna.Repo, path, :up, [all: true])
        rescue
          err -> Logger.warning("error occured, message #{inspect err}")
        end
        Logger.info("migration done")
      _ ->
        Logger.alert("migrations file not present at #{inspect path}")
    end
  end

  defp migrate_down(opts) do
    Logger.info("Rollback database")
    {ch, path} = decide_migration_path(opts)
    step = decide_migration_step(opts)
    Logger.info("rollback database at #{inspect path} with step=#{inspect step}")

    case File.exists?(path) && ch == :ok do
      true -> 
        Logger.info("running rollback")
        try do
          Ecto.Migrator.run(Vienna.Repo, path, :down, [step: step])
        rescue
          err -> Logger.warning("error occured, message #{inspect err}")
        end
        Logger.info("rollback done")
      _ ->
        Logger.alert("migrations file not present at #{inspect path}")
    end
  end

  defp decide_migration_path(opts) do
    Keyword.get(opts, :file)
    |> case do
      nil -> default_migration_path()
      file -> file |> Path.absname()
    end
    |> then(fn f ->
      File.ls(f)
      |> case do
        {:ok, files} -> check_exs_file(f, files)
        err -> 
          Logger.alert("error while reading folder, message #{inspect err}")
          {:error, f}
      end
    end)
  end

  defp check_exs_file(folder, files) do
    Enum.filter(files, &Kernel.==(Path.extname(&1), ".exs"))
    |> case do
      [] -> 
        Logger.alert("chosen folder `#{folder}` not contains .exs files")
        {:error, folder}
      _ -> 
        Logger.info("Found .exs migration files")
        {:ok, folder}
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
    |> tap(fn f -> Logger.info("using default migration file at #{inspect f}") end)
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

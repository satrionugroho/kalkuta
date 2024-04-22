defmodule Berlin.Config do
  use GenServer

  import Berlin.Utils.SafeAtom, only: [to_atom: 1]

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl true
  def init(_opts) do
    Process.send_after(self(), :apply_config, 500)

    {:ok, loaded_config(config_files())}
  end

  @impl true
  def handle_info(:apply_config, state) do
    _ = Enum.map(state, &apply_to_env/1)

    {:noreply, state}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:get, keys}, _from, state) when is_list(keys) do
    Enum.reduce(keys, state, fn k, acc ->
      Keyword.get(acc, k)
    end)
    |> then(fn v -> {:reply, v, state} end)
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    Keyword.get(state, key)
    |> then(fn v -> {:reply, v, state} end)
  end

  @spec config() :: any()
  def config, do: GenServer.call(__MODULE__, :get)

  @spec config(keys :: String.t() | [String.t()]) :: any()
  def config(keys), do: GenServer.call(__MODULE__, {:get, keys})

  defp config_files do
    [
      "$HOME/.config/berlin/config.yml",
      "/etc/berlin/config.yml",
      "$PWD/config.yml",
    ]
  end

  defp loaded_config(files) do
    Enum.map(files, &parse_env/1)
    |> Enum.filter(&File.exists?/1)
    |> List.first()
    |> read_file()
  end

  defp parse_env("$HOME" <> data), do: System.user_home!() <> data
  defp parse_env("$PWD" <> data), do: File.cwd!() <> data
  defp parse_env(data), do: data

  defp read_file(file) do
    :fast_yaml.decode_from_file(file)
    |> case do
      {:ok, [config]} ->
        :logger.info("application loaded with config located in #{file}")
        standardize(config)
      err -> err
    end
  end

  defp standardize(config) when is_list(config) do
    config
    |> Enum.map(&eval_value/1)
  end
  defp standardize(config), do: config

  defp eval_value([_ | _] = list), do: Enum.map(list, &eval_value/1) |> Enum.into(%{})
  defp eval_value({k, v}) when is_list(v) do
    {
      to_atom(k),
      Enum.map(v, &eval_value/1)
    }
  end
  defp eval_value({"ip", v}), do: {:ip, String.split(v, ".") |> Enum.map(&String.to_integer/1) |> List.to_tuple()}
  defp eval_value({"type", "local"}), do: {:type, Berlin.Cache.Local}
  defp eval_value({"type", "redis"}), do: {:type, Berlin.Cache.Redis}
  defp eval_value({"model", v}), do: {:model, to_atom(v)}
  defp eval_value({"hash", v}), do: {:hash, to_atom(v)}
  defp eval_value({k, v}) when v in ["true", "false"], do: {to_atom(k), to_atom(v)}
  defp eval_value({k, v}), do: {to_atom(k), get_from_system_env(v)}
  defp eval_value(value), do: get_from_system_env(value)

  defp get_from_system_env("$" <> name), do: System.get_env(name)
  defp get_from_system_env(name), do: name

  defp apply_to_env({:endpoint, env}) do
    current  = Application.get_env(:berlin, BerlinWeb.Endpoint)
    new_conf = Keyword.merge(current, env)

    :ok = Application.put_env(:berlin, BerlinWeb.Endpoint, new_conf, persistent: true)
    _ = start_child([{Phoenix.PubSub, name: Berlin.PubSub}, BerlinWeb.Endpoint])

    :logger.info("new config loaded to endpoint")
  end

  defp apply_to_env({:database, env}) do
    current  = Application.get_env(:berlin, Berlin.Repo)
    new_conf = Keyword.merge(current, env)
    :ok = Application.put_env(:berlin, Berlin.Repo, new_conf, persistent: true)
    _ = start_child(Berlin.Repo)
    _ = Berlin.Provisions.provision(:migrations)
    :logger.info("new config loaded to repo")
  end

  defp apply_to_env({:cache, env}) do
    current  = Application.get_env(:berlin, Berlin.Cache)
    new_conf = Keyword.merge(current, env)
    model    = Keyword.get(new_conf, :model) |> to_atom()
    levels   = Keyword.get(new_conf, :levels) |> parse_levels()
    cache    = [model: model, levels: levels]

    :ok = Application.put_env(:berlin, Berlin.Cache, cache, persistent: true)

    _ = start_child(Berlin.Cache)

    :logger.info("new config loaded to cache")
  end
  defp apply_to_env(_), do: :ok

  defp parse_levels(levels) do
    Enum.map(levels, fn data ->
      options = Map.delete(data, :type) |> Enum.map(fn {k, v} ->
        value = String.replace(v, "_", "") |> String.to_integer()
        {k, value}
      end) |> Enum.into([])
      type = Map.get(data, :type)

      {type, options}
    end)
  end

  defp start_child([_ | _] = data), do: Enum.map(data, &start_child/1)
  defp start_child(name), do: DynamicSupervisor.start_child(Berlin.Application, name)
end

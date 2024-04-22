defmodule Berlin.TokenHolder do
  use GenServer

  @algos ["RS256"]

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl true
  def init(_arg) do
    {:ok, load_files()}
  end

  @spec get() :: any()
  def get() do
    GenServer.call(__MODULE__, :get)
  end

  @spec jwks() :: any()
  def jwks() do
    GenServer.call(__MODULE__, :jwks)
  end

  @spec sign(data :: map()) :: any()
  def sign(data) do
    GenServer.call(__MODULE__, {:sign, data})
  end

  @spec verify(token :: String.t()) :: any()
  def verify(token) do
    GenServer.call(__MODULE__, {:verify, token})
  end

  @impl  true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @impl  true
  def handle_call(:jwks, _from, state) do
    data = JOSE.JWK.to_map(state) |> elem(1)

    {:reply, [data], state}
  end

  @impl  true
  def handle_call({:verify, token}, _from, state) do
    JOSE.JWT.verify_strict(state, @algos, token)
    |> elem(0)
    |> case do
      true -> {:reply, :ok, state}
      _ -> {:reply, {:error, "unauthenticated"}, state}
    end
  end

  @impl  true
  def handle_call({:sign, data}, _from, jwk) do
    jws = %{"alg" => List.first(@algos)}

    with sig <- JOSE.JWT.sign(jwk, jws, data),
         com <- JOSE.JWS.compact(sig) do
      {:reply, elem(com, 1), jwk}
    else
      _ -> {:reply, nil, jwk}
    end
  end

  defp load_files do
    [
      "/etc/berlin/certs",
      "$PWD/certs"
    ]
    |> do_load_pem()
  end

  defp do_load_pem(folders) do
    Enum.map(folders, &parse_env/1)
    |> Enum.filter(&File.dir?/1)
    |> Enum.map(fn folder ->
      File.ls!(folder)
      |> Enum.map(fn f -> "#{folder}/#{f}" end)
    end)
    |> List.flatten()
    |> Enum.filter(fn f -> Path.extname(f) == ".pem" end)
    |> List.first()
    |> JOSE.JWK.from_pem_file()
  end

  defp parse_env("$HOME" <> data), do: System.user_home!() <> data
  defp parse_env("$PWD" <> data), do: File.cwd!() <> data
  defp parse_env(data), do: data
end

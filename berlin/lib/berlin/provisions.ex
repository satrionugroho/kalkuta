defmodule Berlin.Provisions do
  use GenServer

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl true
  def init(_opts), do: {:ok, %{data: [], time_span: nil, active: false}}

  @impl true
  def handle_cast({:provision, type}, %{data: q} = _state) do
    new_state = %{
      data: [type | q],
      time_span: DateTime.utc_now() |> DateTime.add(2),
      active: true
    }

    Process.send_after(self(), :start_counter, 1000)

    {:noreply, new_state}
  end

  @impl true
  def handle_info(:start_counter, %{data: q, time_span: span, active: true} = state) do
    new_state = case DateTime.compare(DateTime.utc_now(), span) do
      :gt -> _ = do_provision(:lists.reverse(q), state)
      _ ->
        Process.send_after(self(), :start_counter, 1000)
        state
    end

    {:noreply, new_state}
  end

  @impl true
  def handle_info(:start_counter, state), do: {:noreply, state}

  def provision(type) do
    GenServer.cast(__MODULE__, {:provision, type})
  end

  defp do_provision(:migrations, _state) do
    Berlin.Provisions.Migration.migrate()
    :ok
  end
  defp do_provision([head | tail], state) do
    do_provision(head, state)
    |> case do
      :ok -> do_provision(tail, state)
      error ->
        :logger.error("an error occured when provision #{head} with error #{inspect error}")
        error
    end
  end
  defp do_provision(data, _state), do: %{data: data, time_span: nil, active: false}
end

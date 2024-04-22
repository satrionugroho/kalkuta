defmodule Vienna.Server do
  use Application

  def start(_args, _opts) do
    children = [
      {DynamicSupervisor, name: __MODULE__, strategy: :one_for_one}
    ]

    opts = [strategy: :one_for_one, name: Vienna.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

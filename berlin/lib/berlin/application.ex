defmodule Berlin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Berlin.Config,
      Berlin.Provisions,
      BerlinWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:berlin, :dns_cluster_query) || :ignore},
      # Start a worker by calling: Berlin.Worker.start_link(arg)
      # {Berlin.Worker, arg},
      # Start to serve requests, typically the last entry
      Berlin.TokenHolder,
      {DynamicSupervisor, name: Berlin.Application, strategy: :one_for_one}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Berlin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BerlinWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

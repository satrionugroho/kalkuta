# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :berlin,
  ecto_repos: [Berlin.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :berlin, BerlinWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: BerlinWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Berlin.PubSub,
  live_view: [signing_salt: "VcHGL+xy"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :berlin, Berlin.Cache,
  model: :inclusive,
  levels: [
    {
      Berlin.Cache.Local,
      gc_interval: :timer.minutes(10),
      max_size: 1_000_000,
    }
  ]

config :berlin, Berlin.Guardian,
  allowed_algos: ["RS256"],
  issuer: "berlin",
  secret_key: {Berlin.TokenHolder, :get, []}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

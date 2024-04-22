defmodule Berlin.MixProject do
  use Mix.Project

  def project do
    [
      app: :berlin,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: [
        berlin: [
          include_executables_for: [:unix],
          applications: [logger: :permanent, runtime_tools: :permanent],
          steps: [:assemble, &Bakeware.assemble/1],
          bakeware: [
            compression_level: 19,
          ],
          overwrite: true
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Berlin.Application, []},
      extra_applications: extra_applications(Mix.env())
    ]
  end

  defp extra_applications(:dev), do: [:logger, :runtime_tools, :wx, :observer]
  defp extra_applications(_), do: [:logger, :runtime_tools]

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.11"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.2"},
      {:fast_yaml, "~> 1.0"},
      {:ecto_commons, "~> 0.3.4"},
      {:ecto_network, "~> 1.5.0"},

      # JWT
      {:guardian, "~> 2.0"},

      # Encryption
      {:enacl, "~> 1.2.0"},

      # Cache
      {:nebulex, "~> 2.6"},
      {:decorator, "~> 1.4"},
      {:nebulex_redis_adapter, "~> 2.3"},
      {:crc, "~> 0.10"},
      {:jchash, "~> 0.1.3"},

      {:bakeware, "~> 0.2.4", runtime: false},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end

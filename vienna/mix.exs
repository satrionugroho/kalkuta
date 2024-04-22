defmodule Vienna.MixProject do
  use Mix.Project

  def project do
    [
      app: :vienna,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: Vienna],
      releases: releases(),
      preferred_cli_env: [release: :prod],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Vienna, []},
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.11.1"},
      {:postgrex, ">= 0.0.0"},
      {:burrito, "~> 1.0", runtime: false},
      {:bakeware, "~> 0.2.4", runtime: false},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  def releases do
    [
      vienna: [
        overwrite: true,
        quiet: true,
        strip_beams: Mix.env() == :prod,
        steps: [:assemble, &Bakeware.assemble/1],
        bakeware: [
          compression_level: 19,
          start_command: "start_iex",
        ]
      ]
    ]
  end
end

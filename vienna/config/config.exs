import Config

config :vienna, ecto_repos: [Vienna.Repo]

config :vienna, Vienna.Repo,
  username: {System, :get_env, ["DATABASE_USERNAME", "postgres"]},
  hostname: {System, :get_env, ["DATABASE_HOSTNAME", "localhost"]},
  database: "$DATABASE_NAME",
  password: "$DATABASE_PASSWORD"


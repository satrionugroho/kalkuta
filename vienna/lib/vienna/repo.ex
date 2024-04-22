defmodule Vienna.Repo do
  use Ecto.Repo,
    otp_app: :vienna,
    adapter: Ecto.Adapters.Postgres
end

defmodule Berlin.Repo do
  use Ecto.Repo,
    otp_app: :berlin,
    adapter: Ecto.Adapters.Postgres
end

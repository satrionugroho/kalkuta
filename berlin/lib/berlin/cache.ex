defmodule Berlin.Cache do
  use Nebulex.Cache,
    otp_app: :berlin,
    adapter: Nebulex.Adapters.Multilevel

  defmodule Local do
    use Nebulex.Cache,
      otp_app: :berlin,
      adapter: Nebulex.Adapters.Local
  end

  defmodule Redis do
    use Nebulex.Cache,
      otp_app: :berlin,
      adapter: NebulexRedisAdapter
  end
end

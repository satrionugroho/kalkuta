defmodule BerlinWeb.SessionController do
  use BerlinWeb, :controller

  action_fallback BerlinWeb.FallbackController

  @spec create(conn :: Plug.Conn.t(), params :: map()) :: Plug.Conn.t()
  def create(conn, params) do
    with {:ok, user} <- Berlin.Account.validate(params) do
      spawn(fn ->
        Berlin.Account.update_user(user, %{
          login_count: user.login_count + 1,
          last_login_ip: conn.remote_ip,
          last_login_at: DateTime.utc_now(:second),
          password: Map.get(params, "password")
        })
      end)
      render(conn, :create, user: user)
    end
  end
end

defmodule BerlinWeb.RegistrationController do
  use BerlinWeb, :controller

  action_fallback BerlinWeb.FallbackController

  @spec create(conn :: Plug.Conn.t(), params :: map()) :: Plug.Conn.t()
  def create(conn, params) do
    with {:ok, user} <- Berlin.Account.create_user(params) do
      render(conn, :create, user: user)
    end
  end
end

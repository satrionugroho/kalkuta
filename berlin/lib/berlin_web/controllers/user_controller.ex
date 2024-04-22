defmodule BerlinWeb.UserController do
  use BerlinWeb, :controller

  action_fallback BerlinWeb.FallbackController

  @spec create(conn :: Plug.Conn.t(), params :: map()) :: Plug.Conn.t()
  def create(conn, params) do
    with user <- get_current_user(conn),
         {:ok, new_user} <- Berlin.Account.update_user(user, params) do
      render(conn, :create, user: new_user)
    end
  end

  @spec index(conn :: Plug.Conn.t(), params :: map()) :: Plug.Conn.t()
  def index(conn, _params) do
    user = get_current_user(conn)
    render(conn, :index, user: user)
  end

  defp get_current_user(conn) do
    get_in(conn, [Access.key(:assigns, %{}), Access.key(:current_user, %{})])
  end
end

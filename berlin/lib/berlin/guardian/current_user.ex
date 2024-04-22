defmodule Berlin.Guardian.CurrentUser do
  import Plug.Conn

  def init(opts), do: opts

  def call(%{private: private} = conn, _opts) do
    private
    |> Map.get(:guardian_default_claims)
    |> case do
      %{"sub" => sub} when not is_nil(sub) -> fetch_current_user(conn, sub)
      _ -> conn
    end
  end

  defp fetch_current_user(conn, user_id) do
    user = Berlin.Account.get_user!(user_id)
    assign(conn, :current_user, user)
  end
end

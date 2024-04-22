defmodule BerlinWeb.FallbackController do
  use Phoenix.Controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: BerlinWeb.ErrorJSON)
    |> render(:"404")
  end


  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(403)
    |> put_view(json: BerlinWeb.ErrorJSON)
    |> render(:"403")
  end

  def call(conn, {:error, "authentication failed"}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(json: BerlinWeb.ErrorJSON)
    |> render(:"401")
  end
end

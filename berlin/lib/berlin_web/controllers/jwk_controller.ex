defmodule BerlinWeb.JWKController do
  use BerlinWeb, :controller

  def jwk(conn, _params) do
    data = Berlin.TokenHolder.jwks
    render(conn, :jwk, data: data)
  end
end

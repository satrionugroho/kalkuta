defmodule BerlinWeb.JWKJSON do
  @spec jwk(data :: map()) :: map()
  def jwk(%{data: data}) do
    %{keys: data}
  end
end

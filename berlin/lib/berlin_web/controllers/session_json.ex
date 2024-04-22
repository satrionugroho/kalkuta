defmodule BerlinWeb.SessionJSON do

  @spec create(data :: map()) :: map()
  def create(%{user: user}) do
    data  = Map.take(user, [:id, :email, :username, :inserted_at, :updated_at])
    token = %{access_token: Berlin.Guardian.encode_and_sign(user) |> elem(1)}

    %{data: Map.merge(data, token)}
  end
end

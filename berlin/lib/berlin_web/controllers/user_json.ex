defmodule BerlinWeb.UserJSON do
  
  @spec create(data :: map()) :: map()
  def create(%{user: user}) do
    %{data: user_data(user)}
  end

  @spec index(data :: map()) :: map()
  def index(%{user: user}) do
    %{data: user_data(user)}
  end

  defp user_data(user) do
    Map.take(user, [:id, :email, :username, :inserted_at, :updated_at])
  end
end

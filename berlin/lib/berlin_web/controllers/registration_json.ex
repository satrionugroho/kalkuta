defmodule BerlinWeb.RegistrationJSON do

  @doc """
  Renders a single url.
  """
  @spec create(data :: map()) :: map()
  def create(%{user: user}) do
    %{data: Map.take(user, [:id, :email, :username, :inserted_at, :updated_at])}
  end
end

defmodule Berlin.Account do
  use Nebulex.Caching

  @moduledoc """
  The Account context.
  """

  import Ecto.Query, warn: false
  alias Berlin.Repo

  alias Berlin.Account.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id) do
    case get_user(id) do
      nil -> raise Ecto.QueryError, message: "User not found"
      user -> user
    end
  end

  @decorate cacheable(cache: Berlin.Cache, key: {__MODULE__, id})
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @spec validate(params :: map()) :: {:ok, User.t()} | {:error, String.t()}
  def validate(params) do
    email = Map.get(params, "email")
    identity = Map.get(params, "username", email)
    query = from q in User, where: q.email == ^identity or q.username == ^identity, limit: 1
    
    case Repo.one(query) do
      nil -> do_validate(nil, nil)
      user -> do_validate(user, Map.get(params, "password"))
    end
  end

  defp do_validate(user, password) when not is_nil(password) do
    case :enacl.pwhash_str_verify(user.password_digest, password) do
      true -> {:ok, user}
      _ -> do_validate(nil, nil)
    end
  end
  defp do_validate(_user, _password), do: {:error, "authentication failed"}
end

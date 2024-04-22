defmodule Berlin.Account.User do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "users" do
    field :password, :string, virtual: true
    field :password_digest, :binary

    field :email, :string
    field :username, :string

    field :last_login_ip, EctoNetwork.INET
    field :last_login_at, :utc_datetime
    field :login_count, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :password, :last_login_ip, :last_login_at, :login_count])
    |> validate_required([:email, :username, :password])
    |> EctoCommons.EmailValidator.validate_email(:email)
    |> validate_length(:username, min: 4, max: 20)
    |> validate_length(:password, min: 6, max: 64)
    |> validate_format(:password, ~r/[[:lower:]]/, message: "must have at least one lowercase character")
    |> validate_format(:password, ~r/[[:upper:]]/, message: "must have at least one uppercase character")
    |> validate_format(:password, ~r/[[:digit:]]/, message: "must have at least one number")
    |> digest_password()
  end

  defp digest_password(changeset) do
    method = Berlin.Config.config([:encryption, :hash])
    case get_field(changeset, :password) do
      nil -> changeset
      data ->
        result = :enacl.pwhash_str(data, method, method)
        put_change(changeset, :password_digest, result)
    end
  end
end

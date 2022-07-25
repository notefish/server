defmodule User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email
    field :username
    field :hashed_password
    has_many :tokens, Token

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:email, :username, :hashed_password])
    |> validate_required([:email, :username, :hashed_password])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end
end

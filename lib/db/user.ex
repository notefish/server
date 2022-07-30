defmodule User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "users" do
    field :id, :string
    field :email, :string
    field :username, :string
    field :hashed_password, :string
    has_many :tokens, Token, references: :id

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

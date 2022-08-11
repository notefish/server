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
    has_many :spaces, Space, references: :id
    has_many :notes, Note, references: :id

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

  @doc """
  Create a user in the database, alongside their default space. This space is
  created with the same id as the user, and is guaranteed to exist as long as
  this function is used to create new users.
  """
  def create(email, username, hashed_password) do
    {:ok, result} = Notefish.Repo.transaction(fn ->
      user = %User{}
             |> changeset(
               %{
                 email: email,
                 username: username,
                 hashed_password: hashed_password
               })
      with {:ok, user} <- Notefish.Repo.insert(user, returning: true),
           space = %Space{id: user.id, owner_id: user.id, name: "#{username}'s Notes"},
           {:ok, space} <- Notefish.Repo.insert(space, returning: true) do
        # set assocation
        user = Map.put(user, :space, space)
        {:ok, user, space}
      else
        {:error, e} -> {:error, e}
      end
    end)

    result #unwrap transaction
  end
end

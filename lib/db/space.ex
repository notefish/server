defmodule Space do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "spaces" do
    field :id, :string
    field :name, :string
    field :access_public, :boolean
    field :access_users, {:array, :string}

    belongs_to :owner, User, type: :string
  end

  def changeset(space, params \\ %{}) do
    space
    |> cast(params, [:id, :owner_id, :name, :access_public, :access_users])
    |> cast_assoc(:owner)
    |> validate_required([:id, :owner_id, :name])
    |> unique_constraint(:id)
  end
end

defmodule Space do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "spaces" do
    field :id
    field :access_public, :boolean
    field :access_users, {:array, :string}

    belongs_to :owner_id, User, type: :string
  end

  def changeset(space, params \\ %{}) do
    space
    |> cast(params, [:id, :owner_id, :access_public, :access_users])
    |> validate_required([:id, :owner_id])
    |> unique_constraint(:id)
  end
end

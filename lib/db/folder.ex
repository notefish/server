defmodule Folder do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  @derive {Jason.Encoder, only: [
    :id,
    :name,
    :access_public,
    :access_users,
    :space_id,
    :parent_id
  ]}

  schema "folders" do
    field :id, :string
    field :name, :string
    field :access_public, :boolean
    field :access_users, {:array, :string}

    belongs_to :space, Space, type: :string
    belongs_to :parent, Folder, type: :string
  end

  def changeset(folder, params \\ %{}) do
    folder
    |> cast(params, [:id, :space_id, :parent_id, :name, :access_public, :access_users])
    |> cast_assoc(:space)
    |> cast_assoc(:parent)
    |> validate_required([:space_id, :name])
    |> unique_constraint(:id)
    |> unique_constraint([:space_id, :parent_id, :name])
  end
end

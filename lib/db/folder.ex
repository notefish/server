defmodule Folder do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "folders" do
    field :id, :string
    field :name, :string
    field :access_public, :boolean
    field :access_users, {:array, :string}

    belongs_to :space_id, Space, type: :string
    belongs_to :parent_id, Folder, type: :string
  end

  def changeset(folder, params \\ %{}) do
    folder
    |> cast(params, [:id, :space_id, :parent_id, :name, :access_public, :access_users])
    |> validate_required([:space_id, :name])
    |> unique_constraint(:id)
    |> unique_constraint([:space_id, :parent_id, :name])
  end
end

defmodule Note do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "notes" do
    field :id, :string
    field :title, :string
    field :preview, :string
    field :fields, :map

    field :access_public, :boolean
    field :access_users, {:array, :string}

    field :archived, :boolean
    field :hidden, :boolean

    belongs_to :space_id, Space, type: :string
    belongs_to :folder_id, Folder, type: :string
  end

  def changeset(note, params \\ %{}) do
    note
    |> cast(params, [:title, :preview, :fields, :access_public, :access_users, :archived, :hidden, :space_id, :folder_id])
    |> validate_required([:preview, :space_id, :folder_id])
    |> unique_constraint(:id)
  end
end

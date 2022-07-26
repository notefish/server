defmodule Note do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  @derive {Jason.Encoder, only: [
    :id,
    :space_id,
    :title,
    :tags,
    :fields,
    :access_public,
    :access_users,
    :archived,
    :hidden,
    # ensure to preload
    :space,
    :folder,
    :blocks
  ]}

  schema "notes" do
    field :id, :string
    field :title, :string

    field :tags, {:array, :string}
    field :fields, :map

    field :access_public, :boolean
    field :access_users, {:array, :string}

    field :archived, :boolean
    field :hidden, :boolean

    has_many :blocks, Block, references: :id

    belongs_to :space, Space, type: :string
    belongs_to :folder, Folder, type: :string
  end

  def changeset(note, params \\ %{}) do
    note
    |> cast(params, [:title, :tags, :fields, :access_public, :access_users, :archived, :hidden, :space_id, :folder_id])
    |> cast_assoc(:space)
    |> cast_assoc(:folder)
    |> validate_required([:space_id])
    |> unique_constraint(:id)
    |> foreign_key_constraint(:space_id)
    |> foreign_key_constraint(:folder_id)
  end
end

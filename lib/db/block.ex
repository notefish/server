defmodule Block do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "blocks" do
    field :id, :string
    field :body, :string
    field :tags, {:array, :string}
    field :refs, {:array, :string}

    field :rank, :integer

    belongs_to :note, Note, type: :string
    belongs_to :space, Space, type: :string
    belongs_to :parent, Block, type: :string
  end

  def changeset(block, params \\ %{}) do
    block
    |> cast(params, [:body, :tags, :refs, :rank, :note_id, :space_id, :parent_id])
    |> cast_assoc(:note)
    |> cast_assoc(:space)
    |> cast_assoc(:parent)
    |> validate_required([:body, :rank, :note_id, :space_id])
    |> unique_constraint(:id)
    |> unique_constraint([:note_id, :parent_id, :rank])
  end
end

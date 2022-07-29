defmodule Block do
  use Ecto.Schema
  import Ecto.Changeset

  schema "blocks" do
    field :id, :string
    field :body, :string
    field :tags, {:array, :text}
    field :refs, {:array, :text}

    field :index, :integer

    belongs_to :note_id, Note, type: :string
    belongs_to :space_id, Space, type: :string
    belongs_to :parent_id, Block, type: :string
  end

  def changeset(block, params \\ %{}) do
    block
    |> cast(params, [:body, :tags, :refs, :index, :note_id, :space_id, :parent_id])
    |> validate_required([:body, :index, :note_id, :space_id])
    |> unique_constraint(:id)
    |> unique_constraint([:note_id, :parent_id, :index])
  end
end

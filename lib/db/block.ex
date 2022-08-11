defmodule Block do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  @derive {Jason.Encoder, only: [
    :id,
    :body,
    :tags,
    :refs,
    :rank,
    :note_id,
    :space_id
  ]}

  schema "blocks" do
    field :id, :string
    field :body, :string
    field :tags, {:array, :string}
    field :refs, :map

    field :rank, :integer

    belongs_to :note, Note, type: :string
    belongs_to :space, Space, type: :string
  end

  def changeset(block, params \\ %{}) do
    block
    |> cast(params, [:body, :tags, :refs, :rank, :note_id, :space_id])
    |> cast_assoc(:note)
    |> cast_assoc(:space)
    |> validate_required([:body, :rank, :note_id, :space_id])
    |> unique_constraint(:id)
    # doesn't seem to work
    |> unique_constraint([:note_id, :rank])
  end
end

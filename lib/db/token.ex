defmodule Token do
  use Ecto.Schema
  import Ecto.Changeset

  # Do not generate :id field
  @primary_key false

  schema "auth_tokens" do
    field :user_id, :integer
    field :token, :string
    field :device_name, :string
    field :expires, :boolean

    field :created_at, :naive_datetime
  end

  def changeset(token, params \\ %{}) do
    token
    |> cast(params, [:user_id, :token, :device_name, :expires])
    |> validate_required([:user_id, :token, :device_name])
  end
end

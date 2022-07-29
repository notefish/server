defmodule Token do
  use Ecto.Schema
  import Ecto.Changeset

  # Do not generate :id field
  @primary_key false

  schema "auth_tokens" do
    field :user_id, :integer
    field :token
    field :device_name

    field :expires_at, :naive_datetime
    field :created_at, :naive_datetime
  end

  def changeset(token, params \\ %{}) do
    token
    |> cast(params, [:user_id, :token, :device_name, :expires_at])
    |> validate_required([:user_id, :token, :device_name, :expires_at])
  end
end

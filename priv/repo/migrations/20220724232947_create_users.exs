defmodule Notefish.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :text, null: false
      add :username, :text, null: false
      add :hashed_password, :text, null: false

      timestamps(default: fragment("current_date"))
    end

    create unique_index(:users, :email)
    create unique_index(:users, :username)

    create table(:auth_tokens, primary_key: false) do
      add :user_id, references(:users)
      add :token, :text, null: false
      add :device_name, :text, null: false
      add :expires, :boolean, default: false

      add :created_at, :naive_datetime, default: fragment("current_date")
    end

    create unique_index(:auth_tokens, [:user_id, :token])
  end
end

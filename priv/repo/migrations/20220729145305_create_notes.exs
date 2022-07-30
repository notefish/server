defmodule Notefish.Repo.Migrations.CreateNotes do
  use Ecto.Migration

  def change do
    # a space contains notes and folders
    # every user has a default space (that is always private)
    # the id of this default space == id of the user
    # users can create additional spaces, with custom permissions
    # space == root folder
    create table(:spaces, primary_key: false) do
      add :id, :text,
        primary_key: true,
        default: fragment("string_pseudo_encrypt(nextval('nf_serial'))")
      add :name, :text, null: false
      add :owner_id, references(:users, type: :text), null: false
      # publicly accessible
      add :access_public, :boolean, default: false
      # list of user ids granted access
      add :access_users, {:array, :text}, default: []
    end
  
    create unique_index(:spaces, :id)
    create index(:spaces, :access_users, using: :gin) # gin for arrays

    create table(:folders, primary_key: false) do
      add :id, :text,
        primary_key: true,
        default: fragment("string_pseudo_encrypt(nextval('nf_serial'))")
      add :space_id, references(:spaces, type: :text), null: false
      # name includes parents e.g.
      # a/b
      # a/b/c
      add :name, :text, null: false

      add :access_public, :boolean, default: false
      add :access_users, {:array, :text}
    end

    create unique_index(:folders, [:space_id, :name])
    create index(:folders, :access_users, using: :gin) # gin for arrays

    create table(:notes, primary_key: false) do
      add :id, :text,
        primary_key: true,
        default: fragment("string_pseudo_encrypt(nextval('nf_serial'))")
      add :space_id, references(:spaces, type: :text), null: false
      # title may be empty
      add :title, :text, default: ""
      # preview is generated with first few blocks
      # contains no newlines
      add :preview, :text, null: false

      add :tags, {:array, :text}, default: []
      add :fields, :map, default: %{}

      # publicly accessible
      add :access_public, :boolean, default: false
      # list of user ids granted access
      add :access_users, {:array, :text}, default: []
      # both archived and hidden notes are not shown in search by default
      add :archived, :boolean, default: false
      add :hidden, :boolean, default: false
      # null denotes root folder
      add :folder_id, references(:folders, type: :text)
    end

    create index(:notes, :space_id)
    create index(:notes, :title, using: :gin)
    create index(:notes, :access_users, using: :gin)

    create table(:blocks, primary_key: false) do
      add :id, :text,
        primary_key: true,
        default: fragment("string_pseudo_encrypt(nextval('nf_serial'))")
      add :note_id, references(:notes, type: :text)
      add :body, :text, null: false

      add :tags, {:array, :text} # string tags
      add :refs, {:array, :text} # note refs 

      # null is root block
      add :parent_id, :text
      # index is under the parent
      add :rank, :integer

      add :space_id, references(:spaces, type: :text), null: false
    end

    create index(:blocks, :space_id)
    create index(:blocks, :note_id)
    create index(:blocks, :tags, using: :gin)
    create index(:blocks, :refs, using: :gin)
    create unique_index(:blocks, [:note_id, :parent_id, :rank])
  end
end

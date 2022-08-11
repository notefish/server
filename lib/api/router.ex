# make Api.Router to be consistent
defmodule Notefish.ApiRouter do
  use Plug.Router
  import Notefish.Helper

  import Ecto.Query

  # All further matches require authentication
  plug(Notefish.Auth.Plug)

  plug(:match)

  plug(:dispatch)

  @doc """
  Gets the content and metadata for a note.

  Optional parameters:
  
    :blocks (boolean) - Whether or not note blocks (content) is returned.
    :backlinks (boolean) - Whether or not backlinks for this note are returned.

  Default values:

    :blocks - true
    :backlinks - false
  """
  get "/note/:id" do
    # boolean parameters
    fetch_blocks    = parse_bool_param(conn.params, "blocks", true)
    fetch_backlinks = parse_bool_param(conn.params, "backlinks", true)

    preload =
      case fetch_blocks do
        true  -> [:space, :folder, :blocks]
        false -> [:space, :folder]
      end

    query = from n in Note,
      where: n.id == ^conn.params["id"],
      select: n,
      preload: ^preload
    note = Notefish.Repo.one(query)

    note =
      case fetch_blocks do
        true  -> note
        false -> %{note | blocks: nil}
      end

    case note do
      %{} -> send_json(conn, 200, {:ok, note})
      nil -> send_json(conn, 404, {:error, "not_found"})
    end
  end

  @doc """
  Insert or update a note.

  Required parameters:

    :space (id) - The space this note is in.
    :blocks - List of note %Block{}s.

  %Block{
    body: "...",
    tags: ["a", "b", ...], # optional
    refs: ["id1", "id2", ...], # optional
    children: [%Block{}, %Block{}, ...]}

  Optional parameters:

    :id - The id of the note to update.
    :folder (string) - The folder this note is in.
    :title (string) - The note title.
    :tags (string[]) - A list of tag strings in the title.
    :fields ((string, string)[]) - A map of key => value fields.
    :archived (boolean) - Whether or not this note is archived.
  """
  match "/note", via: [:put, :post] do
    conn |> send_json(501, {:error, "not_implemented"})
  end

  @doc """
  Deletes a note.
  """
  delete "/note/:id" do
    conn |> send_json(501, {:error, "not_implemented"})
  end

  @doc """
  Gets a block and its immediate children.

    :full_tree (boolean) - Get the entire tree for this block.
  """
  get "/block/get/:id" do
    conn |> send_json(501, {:error, "not_implemented"})
  end

  @doc """
  Amends the content of a block.

  Required parameters:

    :id - The id of the block to amend.
    :body - The new body.
    :tags - The new tags list.
    :refs - The new refs list.

    :hashlist - A list of hashes for all blocks in this note, ordered.

  Returns:

  {:ok, :updated} - If the block was amended successfully.
  {:error, :diverged} - If the client and server are out of sync as per
                        the hashlist.
  """
  match "/block/amend", via: [:put, :post] do
    conn |> send_json(501, {:error, "not_implemented"})
  end

  @doc """
  Inserts a new block into a note.

  Required parameters:

    :index - The index to insert at.
    :body - The block body.

    :hashlist - A list of hashes for all blocks in this note, ordered.

  Optional parameters:

    :tags - A list of tags used in the body.
    :refs - A list of note references used in the body.

  Returns:

  {:ok, :inserted} - If the block was inserted successfully.
  {:error, :diverged} - If the client and server are out of sync as per
                        the hashlist.
  """
  match "/block/insert", via: [:put, :post] do
    conn |> send_json(501, {:error, "not_implemented"})
  end

  @doc """
  Deletes a block in a note.

  Required parameters:

    :hashlist - A list of hashes for all blocks in this note, ordered.

  Returns:

  {:ok, :deleted} - If the block was deleted successfully.
  {:error, :diverged} - If the client and server are out of sync as per
                        the hashlist.
  """
  delete "/block/:id" do
    conn |> send_json(501, {:error, "not_implemented"})
  end

  @doc """
  Performs a bulk operation on a selection of notes.

  Required parameters:

    :notes (id[]) - A list of notes to perform an operation on.

  Optional parameters:

  The following parameters are mutually exclusive.

    :delete (boolean) - If true, delete all notes selected.

  OR

    :archive (boolean) - If present, update archive status for all notes selected.

  OR

    :space (id) - The folder space.
    :folder (path) - If present, move selected notes to this folder.

  OR

    :put ([string, string]) - A key-value field pair to add to the note.

  OR

    :remove (string) - A field key to clear from the note.
  """
  match "/note/bulk", via: [:put, :post] do
    conn |> send_json(501, {:error, "not_implemented"})
  end

  @doc """
  Performs a query in a space.

  Required parameters:

    :space (id) - The space to query notes in.

  Optional parameters:

    :partial (boolean) - If true, returns only the note metadata (title, preview...)
                         Otherwise, returns full copies.
    :author (id) - The author that the note must have.
    :content (string) - A string of text to search for across note titles and blocks.
    :tags (string[]) - A list of tags to search for across blocks.
    :fields ((string, string)[]) - A list of key => value fields to search for.
    :archived (boolean) - If true, search for archived notes too.

    :sort (edited, created) - The order to return results.
    :per_page (integer) - The number of results per page.

  Defaults:

    :partial  = true
    :author   = logged-in user
    :content  = ""
    :tags     = []
    :fields   = []
    :archived = false
    :sort     = edited
    :per_page = 15

  This endpoint returns a maximum of 20 results per page.
  """
  match "/note/query", via: [:put, :post] do
    conn |> send_json(501, {:error, "not_implemented"})
  end

  @doc """
  Gets the folders in a space. 
  """
  get "/folder/:space_id" do
    conn |> send_json(501, {:error, "not_implemented"})
  end

  @doc """
  Gets the notes that belong to a folder.

  The parameters for this endpoint should contain the full folder path, like:

  /folder/my_space/a/b/c paths to a folder in a hierarchy such that `b` is a
  parent of `c`, and `a` is a parent of `b`.
  """
  get "/folder/:space_id/*path" do
    conn |> send_json(501, {:error, "not_implemented"})
  end

  @doc """
  Creates a folder under a space.
  """
  match "/folder/:space_id/*path", via: [:put, :post] do
    conn |> send_json(501, {:error, "not_implemented"})
  end

  @doc """
  Deletes a folder under a space.
  """
  delete "/folder/:space_id/*path" do
    conn |> send_json(501, {:error, "not_implemented"})
  end

  @doc """
  Gets all used tags under a space.
  """
  get "/tags/:space_id" do
    conn |> send_json(501, {:error, "not_implemented"})
  end

  @doc """
  Gets all used field keys under a space.
  """
  get "/fields/:space_id" do
    conn |> send_json(501, {:error, "not_implemented"})
  end

  match _ do 
    conn |> send_json(501, {:error, "unknown_method"})
  end
end

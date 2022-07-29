defmodule Notefish.NotesRouter do
  use Plug.Router

  plug(:match)

  plug(:dispatch)

  get "/" do
    IO.inspect conn.assigns
  end
end

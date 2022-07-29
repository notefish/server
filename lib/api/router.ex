defmodule Notefish.ApiRouter do
  use Plug.Router

  # All further matches require authentication
  plug(Notefish.Auth.Plug)

  plug(:match)

  plug(:dispatch)

  forward "/note", to: Notefish.NotesRouter

  match _ do 
    send_resp(conn, 500, "unknown method")
  end
end

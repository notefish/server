defmodule Notefish.ApiRouter do
  use Plug.Router

  plug(:match)

  plug(:dispatch)

  # All further matches require authentication
  plug(Notefish.Auth.Plug)

  match _ do 
    send_resp(conn, 500, "unknown method")
  end
end

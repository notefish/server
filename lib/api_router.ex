defmodule Notefish.ApiRouter do
  use Plug.Router

  plug(:match)

  plug(:dispatch)

  get "/hello" do
    send_resp(conn, 200, "world")
  end

  match _ do 
    send_resp(conn, 500, "unknown method")
  end
end

defmodule Notefish.Static do
  use Plug.Builder

  plug Plug.Static.IndexHtml,
    at: "/"
  plug Plug.Static,
    at: "/",
    from: {:notefish, "priv/client/dist"}
  plug :not_found

  def not_found(conn, _) do
    send_resp(conn, 404, "not found")
  end
end

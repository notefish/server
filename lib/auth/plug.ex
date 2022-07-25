defmodule Notefish.Auth.Plug do
  import Plug.Conn
  import Ecto.Query

  import Notefish.Auth

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    if not conn_authorized?(conn) do
      conn
      |> halt()
    else
      # authorized
      conn
    end
  end
end

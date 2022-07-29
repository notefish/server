defmodule Notefish.Auth.Plug do
  import Plug.Conn
  import Ecto.Query

  import Notefish.Auth
  import Notefish.Helper

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    with {:ok, user_id} <- verify_connection(conn) do
      conn
      |> assign(:user_id, user_id)
    else
      {:error, reason} ->
        conn 
        |> send_json(401, {:error, reason})
        |> halt()
    end
  end
end

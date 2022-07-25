defmodule Notefish.Helper do
  import Plug.Conn

  def send_json(conn, code, map = %{}) do
    send_resp(conn, code, Jason.encode!(map))
  end

  def send_json(conn, code, tuple) when is_tuple(tuple) do
    send_resp(conn, code, Jason.encode!(tuple))
  end

  def check_params(params = %{}, required_keys) do
    missing_keys = required_keys -- Map.keys(params)
    if Enum.empty?(missing_keys) do
      :ok
    else
      {:missing, missing_keys}
    end
  end
end

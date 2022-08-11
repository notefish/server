defmodule Notefish.Helper do
  import Plug.Conn

  def send_json(conn, code, map = %{}) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(code, Jason.encode!(map))
  end

  def send_json(conn, code, tuple) when is_tuple(tuple) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(code, Jason.encode!(tuple))
  end

  def parse_bool_param(params, key, default \\ false) do
      case params[key] do
        "true" -> true
        ""     -> true
        _      -> false
      end
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

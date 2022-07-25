defmodule Notefish.Auth do
  @moduledoc """
  Provides necessary utility to Auth services.
  """
  import Plug.Conn
  import Ecto.Query

  @token_expiry Application.fetch_env!(:notefish, :token_expiry)

  def generate_token(user = %User{}, device_name, expires) do
    token = :crypto.strong_rand_bytes(32)
            |> Base.encode64()
    IO.inspect token
    struct = %Token{}
            |> Map.put(:user_id, user.id)
            |> Map.put(:token, token)
            |> Map.put(:device_name, device_name)
            |> Map.put(:expires, expires)
    case Notefish.Repo.insert(struct) do
      {:ok, _}    -> {:ok, token}
      {:error, c} -> {:error, c}
    end
  end

  def conn_authorized?(conn, expire_in \\ @token_expiry) do
    case get_req_header(conn, "authorization") do
      [token] -> token_authorized?(token, expire_in)
      _       -> false
    end
  end

  def token_authorized?("Bearer " <> token, expire_in \\ @token_expiry) do
    # query database
    query = from t in Token,
      where: t.token == ^token,
      select: t
    with t = %Token{} <- Notefish.Repo.one(query) do
      now = NaiveDateTime.local_now()
      time_existed = NaiveDateTime.diff(now, t.created_at, :second)
                     |> div(60*60) # to hours

      token_invalid = t.expires and time_existed >= expire_in
      not token_invalid
    else
      _ -> false
    end
  end

end

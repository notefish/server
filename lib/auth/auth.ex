defmodule Notefish.Auth do
  @moduledoc """
  Provides necessary utility to Auth services.
  """
  import Plug.Conn
  import Ecto.Query

  @expiry Application.fetch_env!(:notefish, :token_expiry)

  def generate_token(user = %User{}, device_name, remember_me) do
    token = :crypto.strong_rand_bytes(32)
           |> Base.encode64()

    expires_in = 
      case remember_me do
        true  -> @expiry[:remember_me]
        false -> @expiry[:default]
      end

    expires_at = NaiveDateTime.local_now()
                 |> NaiveDateTime.add(expires_in * 3600, :second)

    struct = %Token{}
            |> Map.put(:user_id, user.id)
            |> Map.put(:token, token)
            |> Map.put(:device_name, device_name)
            |> Map.put(:expires_at, expires_at)
    case Notefish.Repo.insert(struct) do
      {:ok, _}    -> {:ok, token}
      {:error, c} -> {:error, c}
    end
  end

  def verify_connection(conn) do
    case get_req_header(conn, "authorization") do
      [value] -> verify_auth_header(value)
      _       -> {:error, :token_not_present}
    end
  end

  def verify_auth_header("Bearer " <> token) do
    query = from t in Token,
      where: t.token == ^token,
      select: t
    with t = %Token{} <- Notefish.Repo.one(query) do
      now = NaiveDateTime.local_now()
      # expires_at is in the future (:gt now)
      if NaiveDateTime.compare(t.expires_at, now) == :gt do
        {:ok, t.user_id}
      else
        {:error, :token_expired}
      end
    else
      _ -> {:error, :token_deleted}
    end
  end

  def verify_auth_header(bad_token) do
    {:error, :token_not_present}
  end
end

defmodule Notefish.Auth.Router do
  use Plug.Router
  import Notefish.Helper

  import Ecto.Query

  @salt Application.fetch_env!(:notefish, :bcrypt_salt)

  plug(:match)

  plug(:dispatch)

  @doc """
  Verifies that the given token is still valid.
  """
  get "/" do
    case Notefish.Auth.verify_connection(conn) do
      {:ok, user_id} ->
        send_json(conn, 200, {:ok, "token_valid"})
      {:error, :token_not_present} ->
        send_json(conn, 400, {:error, "token_not_present"}) 
      {:error, _} ->
        send_json(conn, 400, {:error, "token_expired"})
    end
  end

  @doc """
  Tries to login with the provided username and password.

    :login    - May be a username or email address.
    :password - Password (client-side hashed.)
  """
  match "/login", via: [:put, :post] do
    required_keys = ["login", "password", "device_name", "remember_me"]
    with :ok <- check_params(conn.body_params, required_keys) do
      %{"login" => login,
        "password" => password,
        "device_name" => device_name,
        "remember_me" => remember_me} = conn.body_params

      query = from u in User,
        where: u.username == ^login or u.email == ^login,
        select: u
      with user = %User{} <- Notefish.Repo.one(query),
           true <- Bcrypt.Base.hash_password(password, @salt) == user.hashed_password,
           {:ok, token} <- Notefish.Auth.generate_token(user, device_name, remember_me) do
        # OK, authorize the login
        send_json(conn, 200, {:ok, "token_granted", token})
      else
        _ -> send_json(conn, 401, {:error, "bad_credentials"})
      end
    else
      {:missing, expected} ->
        missing_keys = Enum.join(expected, ", ")
        send_json(conn, 400, {:error, "missing_keys", missing_keys})
    end
  end

  @doc """
  Registers with the provided username and password.

    :email (optional) - Email to link to the account.
    :username         - Username to register.
    :password         - Password to register.
  """
  match "/register", via: [:put, :post] do
    required_keys = ["email", "username", "password", "device_name", "remember_me"]
    with :ok <- check_params(conn.body_params, required_keys) do
      hashed_password = 
        Bcrypt.Base.hash_password(conn.body_params["password"], @salt)

      params = conn.body_params
               |> Map.put("hashed_password", hashed_password)
      user = User.changeset(%User{}, params)

      case Notefish.Repo.insert(user, returning: [:id]) do
        {:ok, user} ->
          # generate a token
          device_name = Map.get(conn.body_params, "device_name")
          remember_me = Map.get(conn.body_params, "remember_me")
          with {:ok, token} <- Notefish.Auth.generate_token(user, device_name, remember_me) do
            send_json(conn, 200, {:ok, "token_granted", token})
          else
            _ -> send_json(conn, 500, {:error, "token_failure"})
          end
        {:error, changeset} ->
          conn |> send_json(400, {:error, "validation_failed", changeset.errors})
      end
    else
      {:missing, expected} ->
        missing_keys = Enum.join(expected, ", ")
        send_json(conn, 400, {:error, "missing_keys", missing_keys})
    end
  end

  @doc """
  Mails a reset-password form if the User has an email attached.

    :username - May be a username or email address.
  """
  match "/reset", via: [:put, :post] do
    send_json(conn, 501, {:error, "not_implemented"})
  end

  @doc """
  Resets the password of a User, if given a valid reset :code.

    :password - New password (client-side hashed.)
  """
  match "/reset/:code", via: [:put, :post] do
    send_json(conn, 501, {:error, "not_implemented"})
  end

  match _ do 
    send_json(conn, 500, {:error, "unknown_method"})
  end
end

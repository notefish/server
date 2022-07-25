defmodule AuthTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @salt Application.fetch_env!(:notefish, :bcrypt_salt)

  @email "john.doe@gmail.com"
  @username "john321"
  @password "password123"

  # drop all
  Notefish.Repo.delete_all(Token)
  Notefish.Repo.delete_all(User)

  # test user
  {:ok, _} = Notefish.Repo.insert(%User{
    email: @email,
    username: @username,
    hashed_password: Bcrypt.Base.hash_password(@password, @salt)
  })

  test "/: (verify) fails with no token" do
    conn =
      conn(:get, "/")
      |> Notefish.Auth.Router.call(%{})

    assert Jason.decode!(conn.resp_body) == ["error", "token_invalid"]
  end

  test "/register: fails with bad body" do
    # missing email + password
    conn =
      conn(:put, "/register")
      |> Map.put(:body_params, %{
          "username" => @username,
          "device_name" => "test script",
          "remember_me" => false})
      |> Notefish.Auth.Router.call(%{})

    assert conn.status == 400

    parsed = Jason.decode!(conn.resp_body)
    ["error", "missing_keys", reason] = parsed
  end


  test "/register: fails for duplicate email" do
    conn =
      conn(:put, "/register")
      |> Map.put(:body_params, %{
          "email" => @email,
          "username" => @username <> "1",
          "password" => @password,
          "device_name" => "test script",
          "remember_me" => false})
      |> Notefish.Auth.Router.call(%{})

    assert conn.status == 400

    parsed = Jason.decode!(conn.resp_body)
    ["error", "validation_failed", errors] = parsed
  end

  test "/register: fails for duplicate username" do
    conn =
      conn(:put, "/register")
      |> Map.put(:body_params, %{
          "email" => @email <> "1",
          "username" => @username,
          "password" => @password,
          "device_name" => "test script",
          "remember_me" => false})
      |> Notefish.Auth.Router.call(%{})

    assert conn.status == 400

    parsed = Jason.decode!(conn.resp_body)
    ["error", "validation_failed", errors] = parsed
  end

  test "/register: succeeds for new details" do
    conn =
      conn(:put, "/register")
      |> Map.put(:body_params, %{
          "email" => @email <> "1",
          "username" => @username <> "1",
          "password" => @password,
          "device_name" => "test script",
          "remember_me" => false})
      |> Notefish.Auth.Router.call(%{})
    IO.inspect conn.resp_body
    assert conn.status == 200

    parsed = Jason.decode!(conn.resp_body)
    ["ok", "token_granted", token] = parsed
    assert token != nil
  end

  test "/login: fails for bad request" do
    # no password
    conn =
      conn(:put, "/login")
      |> Map.put(:body_params, %{
          "login" => @email,
          "device_name" => "test script",
          "remember_me" => false})
      |> Notefish.Auth.Router.call(%{})
    IO.inspect conn.resp_body
    assert conn.status == 400

    parsed = Jason.decode!(conn.resp_body)
    ["error", "missing_keys", expected] = parsed
    assert expected != nil
  end

  test "/login: fails for bad details" do
    # username is changed
    conn =
      conn(:put, "/login")
      |> Map.put(:body_params, %{
          "login" => @username <> "2",
          "password" => @password,
          "device_name" => "test script",
          "remember_me" => false})
      |> Notefish.Auth.Router.call(%{})
    IO.inspect conn.resp_body
    assert conn.status == 401

    parsed = Jason.decode!(conn.resp_body)
    ["error", "bad_credentials"] = parsed

    # password is changed
    conn =
      conn(:put, "/login")
      |> Map.put(:body_params, %{
          "login" => @username,
          "password" => @password <> "1",
          "device_name" => "test script",
          "remember_me" => false})
      |> Notefish.Auth.Router.call(%{})
    IO.inspect conn.resp_body
    assert conn.status == 401

    parsed = Jason.decode!(conn.resp_body)
    ["error", "bad_credentials"] = parsed
  end

  test "/login: grants token for correct details" do
    # with email
    conn =
      conn(:put, "/login")
      |> Map.put(:body_params, %{
          "login" => @email,
          "password" => @password,
          "device_name" => "test script",
          "remember_me" => false})
      |> Notefish.Auth.Router.call(%{})
    IO.inspect conn.resp_body
    assert conn.status == 200

    parsed = Jason.decode!(conn.resp_body)
    ["ok", "token_granted", token] = parsed
    assert token != nil

    # with username
    conn =
      conn(:put, "/login")
      |> Map.put(:body_params, %{
          "login" => @username,
          "password" => @password,
          "device_name" => "test script",
          "remember_me" => false})
      |> Notefish.Auth.Router.call(%{})
    IO.inspect conn.resp_body
    assert conn.status == 200

    parsed = Jason.decode!(conn.resp_body)
    ["ok", "token_granted", token] = parsed
    assert token != nil
  end
end

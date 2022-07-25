defmodule Notefish.Router do
  use Plug.Router

  plug(Plug.Logger)

  plug(:match)

  plug Plug.Parsers,
       parsers: [:urlencoded, :json],
       json_decoder: Jason

  plug(:dispatch)

  forward "/auth", to: Notefish.Auth.Router

  forward "/api/v1", to: Notefish.ApiRouter

  forward "/", to: Notefish.Static
end

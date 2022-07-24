defmodule Notefish.Router do
  use Plug.Router

  plug(Plug.Logger)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  forward "/api", to: Notefish.ApiRouter

  forward "/", to: Notefish.Static
end

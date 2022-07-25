defmodule Notefish.Application do
  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      Notefish.Repo,
      {Plug.Cowboy, scheme: :http, plug: Notefish.Router, options: [port: 3000]}
    ]

    Logger.info "Listening for requests on *:3000"

    opts = [strategy: :one_for_one, name: Notefish.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

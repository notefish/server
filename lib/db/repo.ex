defmodule Notefish.Repo do
  use Ecto.Repo,
    otp_app: :notefish,
    adapter: Ecto.Adapters.Postgres
end

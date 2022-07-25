import Config

config :notefish, Notefish.Repo,
  database: "notefish_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"

config :notefish,
  ecto_repos: [Notefish.Repo]

import_config "#{config_env()}.exs"

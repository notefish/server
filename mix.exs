defmodule Server.MixProject do
  use Mix.Project

  def project do
    [
      app: :notefish,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ecto, :postgrex],
      mod: {Notefish.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:plug_cowboy, "~> 2.5.2"},
      {:jason, "~> 1.3"},
      {:plug_static_index_html, "~> 1.0"},
      {:postgrex, "~> 0.16.0"},
      {:ecto, "~> 3.8.4"},
      {:ecto_sql, "~> 3.8.3"},
      {:bcrypt_elixir, "~> 3.0.1"},
    ]
  end
end

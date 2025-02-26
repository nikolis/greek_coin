defmodule GreekCoin.MixProject do
  use Mix.Project

  def project do
    [
      app: :greek_coin,
      version: "0.1.1",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {GreekCoin.Application, []},
      extra_applications: [:confex, :logger, :runtime_tools, :bamboo, :ssl]
      
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:confex, "~> 3.4.0"},
      {:nio_google_authenticator, git: "https://github.com/nikolisgal/nio_google_authenticator.git"},
      {:kerosene, "~> 0.9.0"},
      {:httpoison, "~> 1.7" },
      {:ex_crypto, "~> 0.10.0"},
      {:cors_plug, "~> 1.5"},
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:s3_direct_upload, "~> 0.1.0"},
      {:guardian, "~> 2.0"},
      {:argon2_elixir, "~> 2.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:comeonin, "~> 5.1.1"},   
      {:bcrypt_elixir, "~> 2.0"},    
      {:pbkdf2_elixir, "~> 1.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:bamboo, "~> 1.3"},
      {:bamboo_smtp, "~> 2.0.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:distillery, "~> 2.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end

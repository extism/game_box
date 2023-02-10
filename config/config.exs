# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :game_box,
  ecto_repos: [GameBox.Repo]

# Configures the endpoint
config :game_box, GameBoxWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: GameBoxWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: GameBox.PubSub,
  live_view: [signing_salt: "I1PjC40z"]

config :game_box, GameBox.Games, path: Path.expand("../priv/data", __DIR__)

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :game_box, disk_volume_path: "priv/static/uploads"

config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, default_scope: "user:email"}
  ]

# override
config :game_box, password: "12345"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

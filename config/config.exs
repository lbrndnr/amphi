# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :amphi, Amphi.Repo,
  database: "amphi_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"

config :crawly,
  closespider_timeout: 10,
  concurrent_requests_per_domain: 8,
  fetcher: {Crawly.Fetchers.Splash, [base_url: "http://localhost:8050/render.html"]},
  middlewares: [
    # Crawly.Middlewares.DomainFilter,
    # Crawly.Middlewares.UniqueRequest,
    # Crawly.Middlewares.AutoCookiesManager,
    {Crawly.Middlewares.RequestOptions, [follow_redirect: true]},
    {Crawly.Middlewares.UserAgent, user_agents: ["Crawly Bot"]}
  ]

config :amphi,
  ecto_repos: [Amphi.Repo]

# Configures the endpoint
config :amphi, AmphiWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: AmphiWeb.ErrorHTML, json: AmphiWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Amphi.PubSub,
  live_view: [signing_salt: "GMUk2GFl"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :amphi, Amphi.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2021 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
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

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

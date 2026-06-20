# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :inertia, endpoint: TemplateAppWeb.Endpoint

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :template_app, Oban,
  engine: Oban.Engines.Basic,
  notifier: Oban.Notifiers.Postgres,
  plugins: [
    {Oban.Plugins.Lifeline, rescue_after: to_timeout(minute: 10)}
  ],
  queues: [default: 10],
  repo: TemplateApp.Repo,
  shutdown_grace_period: to_timeout(minute: 4)

# Configure the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :template_app, TemplateApp.Mailer, adapter: Swoosh.Adapters.Local

# Configure the endpoint
config :template_app, TemplateAppWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: TemplateAppWeb.ErrorHTML, json: TemplateAppWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: TemplateApp.PubSub,
  live_view: [signing_salt: "DT3CKWvf"]

config :template_app, :scopes,
  user: [
    default: true,
    module: TemplateApp.Accounts.Scope,
    assign_key: :current_scope,
    access_path: [:user, :id],
    schema_key: :user_id,
    schema_type: :id,
    schema_table: :users,
    test_data_fixture: TemplateApp.Factory,
    test_setup_helper: :register_and_log_in_user
  ]

config :template_app,
  ecto_repos: [TemplateApp.Repo],
  generators: [timestamp_type: :utc_datetime],
  env: config_env()

import_config "#{config_env()}.exs"

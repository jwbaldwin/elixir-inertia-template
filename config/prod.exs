import Config

# Do not print debug messages in production
config :logger, level: :info

# Configure Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Req

# Runtime production configuration, including reading

# Disable Swoosh Local Memory Storage
# of environment variables, is done on config/runtime.exs.
config :swoosh, local: false

# TLS termination and HTTP-to-HTTPS redirects are handled by Kamal proxy.
# Keep force_ssl disabled to avoid duplicate proxy/app redirects.
config :template_app, TemplateAppWeb.Endpoint, force_ssl: false

import Config

dotenv_vars = Dotenvy.source!([Path.expand("../.env", __DIR__), Path.expand("../.env.local", __DIR__), System.get_env()])
System.put_env(dotenv_vars)

# config/runtime.exs is executed for all environments, including releases.
# Keep runtime-only configuration here so releases can be configured through environment variables.

if System.get_env("PHX_SERVER") do
  config :template_app, TemplateAppWeb.Endpoint, server: true
end

config :template_app, TemplateAppWeb.Endpoint, http: [port: String.to_integer(System.get_env("PORT", "4000"))]

if config_env() == :prod do
  database_url = System.fetch_env!("DATABASE_URL")
  pool_size = String.to_integer(System.get_env("POOL_SIZE", "10"))
  secret_key_base = System.fetch_env!("SECRET_KEY_BASE")
  host = System.fetch_env!("PHX_HOST")
  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :template_app, TemplateApp.Repo,
    url: database_url,
    pool_size: pool_size,
    socket_options: maybe_ipv6

  config :template_app, TemplateAppWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [ip: {0, 0, 0, 0, 0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT", "4000"))],
    secret_key_base: secret_key_base

  config :template_app, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")
end

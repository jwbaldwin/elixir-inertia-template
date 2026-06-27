defmodule TemplateApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :template_app,
      version: "0.1.0",
      elixir: "~> 1.19",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:boundary] ++ quality_compilers() ++ [:phoenix_live_view] ++ Mix.compilers(),
      unused: [
        severity: :hint,
        ignore: [
          {:_, :child_spec, 1},
          {:_, ~r/^__.*__\??$/, :_},
          {~r/^TemplateAppWeb\..*Controller$/, :_, 2..3},
          {TemplateAppWeb.Router, :_, 2},
          TemplateAppWeb,
          TemplateAppWeb.Endpoint,
          TemplateAppWeb.CoreComponents,
          TemplateAppWeb.Layouts,
          TemplateAppWeb.ErrorHTML,
          TemplateAppWeb.ErrorJSON,
          TemplateAppWeb.Telemetry,
          TemplateApp.Mailer,
          TemplateApp.Repo,
          TemplateApp.Release,
          TemplateApp.DataCase,
          TemplateAppWeb.ConnCase,
          TemplateApp.Factory,
          TemplateApp.TestHelpers
        ]
      ],
      listeners: [Phoenix.CodeReloader]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {TemplateApp.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def cli do
    [
      preferred_envs: [check: :test, precommit: :test, "test.interactive": :test]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp quality_compilers do
    if Mix.env() in [:dev, :test], do: [:unused], else: []
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:argon2_elixir, "~> 4.0"},
      {:inertia, "~> 2.0"},
      {:phoenix, "~> 1.8.3"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.13"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.1.0"},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:ex_machina, "~> 2.8", only: :test},
      {:mimic, "~> 2.3", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:swoosh, "~> 1.16"},
      {:req, "~> 0.5"},
      {:bodyguard, "~> 2.4"},
      {:dotenvy, "~> 1.1"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:oban, "~> 2.20"},
      {:oban_web, "~> 2.11"},
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.5"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:boundary, "~> 0.11", runtime: false},
      {:ex_check, "~> 0.17", only: [:dev, :test], runtime: false},
      {:ex_dna, "~> 1.5", only: [:dev, :test], runtime: false},
      {:ex_slop, "~> 0.4", only: [:dev, :test], runtime: false},
      {:excellent_migrations, "~> 0.1.10", only: [:dev, :test], runtime: false},
      {:jump_credo_checks, "~> 0.5", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      {:mix_unused, "~> 0.4", only: [:dev, :test], runtime: false},
      {:reach, "~> 2.8", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.16", only: [:dev, :test], runtime: false},
      {:styler, "~> 1.10", only: [:dev, :test], runtime: false},
      {:mix_test_interactive, "~> 5.1", only: [:dev, :test], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd --cd assets bun install"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "fe.setup": ["cmd --cd assets bun install"],
      "fe.build": ["cmd --cd assets bun run build"],
      "assets.deploy": ["cmd --cd assets bun run build", "phx.digest"],
      "fe.lint": ["cmd --cd assets bun run lint"],
      "fe.format": ["cmd --cd assets bun run format"],
      "fe.format.check": ["cmd --cd assets bun run format:check"],
      lint: ["credo"],
      "lint.full": ["lint", "fe.lint"],
      "format.full": ["format", "fe.format"],
      "format.check.full": ["format --check-formatted", "fe.format.check"],
      precommit: ["check"]
    ]
  end
end

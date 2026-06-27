[
  retry: false,
  tools: [
    {:compiler, env: %{"MIX_ENV" => "test"}},
    {:credo, "mix credo --strict"},
    {:sobelow, "mix sobelow --exit low --private"},
    {:ex_dna, "mix ex_dna"},
    {:reach_arch, "mix reach.check --arch"},
    {:npm_test, false},
    {:frontend_format, "bun run format:check", cd: "assets"},
    {:frontend_lint, "bun run lint", cd: "assets"},
    {:frontend_types, "bun run typecheck", cd: "assets"},
    {:frontend_test, "bun run test", cd: "assets"},
    {:frontend_build, "bun run build", cd: "assets"}
  ]
]

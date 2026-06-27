[
  layers: [
    startup: ["TemplateApp.Application"],
    web: ["TemplateAppWeb", "TemplateAppWeb.*"],
    domain: ["TemplateApp", "TemplateApp.*"]
  ],
  deps: [
    forbidden: [{:domain, :web}, {:domain, :startup}, {:web, :startup}]
  ],
  checks: [source_paths: ["lib"]]
]

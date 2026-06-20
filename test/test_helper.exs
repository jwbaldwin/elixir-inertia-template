{:ok, _} = Application.ensure_all_started(:ex_machina)
TemplateApp.TestSupport.Mimic.copy_modules()
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(TemplateApp.Repo, :manual)

defmodule TemplateApp.ObanConfigTest do
  use ExUnit.Case, async: true

  test "configures default queue, deploy shutdown grace, and orphan rescue" do
    oban_config = Application.fetch_env!(:template_app, Oban)

    assert Keyword.fetch!(oban_config, :shutdown_grace_period) == to_timeout(minute: 4)
    assert Keyword.fetch!(oban_config, :queues) == [default: 10]
    assert {Oban.Plugins.Lifeline, rescue_after: to_timeout(minute: 10)} in Keyword.fetch!(oban_config, :plugins)
  end
end

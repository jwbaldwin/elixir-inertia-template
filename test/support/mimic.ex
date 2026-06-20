defmodule TemplateApp.TestSupport.Mimic do
  @moduledoc false

  def copy_modules do
    Mimic.copy(Req)
  end
end

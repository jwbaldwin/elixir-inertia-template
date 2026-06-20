defmodule TemplateAppWeb.HealthController do
  use TemplateAppWeb, :controller

  def show(conn, _params) do
    json(conn, %{status: "ok"})
  end
end

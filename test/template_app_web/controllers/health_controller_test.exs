defmodule TemplateAppWeb.HealthControllerTest do
  use TemplateAppWeb.ConnCase, async: true

  test "GET /healthz", %{conn: conn} do
    resp =
      conn
      |> get(~p"/healthz")
      |> json_response(200)

    assert %{"status" => "ok"} = resp
  end
end

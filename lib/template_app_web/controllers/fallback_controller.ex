defmodule TemplateAppWeb.FallbackController do
  use TemplateAppWeb, :controller

  @generic_error_statuses [400, 401, 403, 404, 422, 500]

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_flash(:error, "You do not have permission to perform this action.")
    |> redirect(to: ~p"/")
  end

  def call(conn, {:error, :no_active_organization}) do
    conn
    |> put_flash(:error, "Select an organization to manage settings.")
    |> redirect(to: ~p"/")
  end

  def call(conn, {:error, :bad_request}), do: render_error(conn, 400)
  def call(conn, {:error, :unauthorized}), do: render_error(conn, 401)
  def call(conn, {:error, :not_found}), do: render_error(conn, 404)
  def call(conn, {:error, {:not_found, _message}}), do: render_error(conn, 404)
  def call(conn, {:error, :unprocessable_entity}), do: render_error(conn, 422)
  def call(conn, {:error, :internal_server_error}), do: render_error(conn, 500)

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, &TemplateAppWeb.CoreComponents.translate_error/1)})
  end

  def call(conn, {:error, status}) when is_integer(status) and status in @generic_error_statuses do
    render_error(conn, status)
  end

  defp render_error(conn, 404) do
    if json_error_request?(conn) do
      render_json_error(conn, 404)
    else
      conn
      |> put_status(:not_found)
      |> assign_prop(:status, 404)
      |> assign_prop(:message, "Not Found")
      |> render_inertia("errors/not-found")
    end
  end

  # ErrorHTML returns a fixed status message; no request content enters this response.
  # sobelow_skip ["XSS.SendResp"]
  defp render_error(conn, status) do
    if json_error_request?(conn) do
      render_json_error(conn, status)
    else
      send_resp(conn, status, TemplateAppWeb.ErrorHTML.render("#{status}.html", %{}))
    end
  end

  defp render_json_error(conn, status) do
    conn
    |> put_status(status)
    |> json(TemplateAppWeb.ErrorJSON.render("#{status}.json", %{}))
  end

  defp json_error_request?(conn) do
    String.starts_with?(conn.request_path, "/api/") or "json" in Map.get(conn, :accepts, []) or accepts_json?(conn) or
      xhr?(conn)
  end

  defp accepts_json?(conn) do
    conn
    |> get_req_header("accept")
    |> Enum.any?(&String.contains?(&1, "application/json"))
  end

  defp xhr?(conn) do
    conn
    |> get_req_header("x-requested-with")
    |> Enum.any?(&(&1 == "XMLHttpRequest"))
  end
end

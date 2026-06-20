defmodule TemplateApp.Repo do
  use Ecto.Repo,
    otp_app: :template_app,
    adapter: Ecto.Adapters.Postgres

  def normalize_one(result) do
    case result do
      nil -> {:error, :not_found}
      result -> {:ok, result}
    end
  end

  def normalize_result(result, message) do
    case result do
      nil -> {:error, {:not_found, message}}
      result -> {:ok, result}
    end
  end
end

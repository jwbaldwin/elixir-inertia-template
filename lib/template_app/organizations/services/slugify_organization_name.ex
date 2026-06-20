defmodule TemplateApp.Organizations.Services.SlugifyOrganizationName do
  @moduledoc """
  Slugifies an organization name
  e.g. "My Company" -> "my-company"
  """

  @doc @moduledoc
  @spec call(String.t()) :: String.t() | {:error, term()}
  def call(value) when is_binary(value) do
    value
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/\s+/, "-")
    |> String.replace(~r/-+/, "-")
    |> String.trim("-")
    |> case do
      "" -> "your-company"
      slug -> slug
    end
  end

  def call(_), do: {:error, "value must be a string"}
end

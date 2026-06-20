defmodule TemplateApp.Organizations.Values.Organization do
  @moduledoc """
  Builds organization payloads for web responses
  """

  @doc @moduledoc
  def build(organization) do
    %{
      id: organization.id,
      name: organization.name,
      slug: organization.slug
    }
  end
end

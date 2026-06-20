defmodule TemplateApp.Organizations.Values.Member do
  @moduledoc """
  Builds organization member payloads for web responses
  """

  @doc @moduledoc
  def build(memberships) when is_list(memberships) do
    Enum.map(memberships, &build/1)
  end

  def build(membership) do
    %{
      id: membership.id,
      user_id: membership.user_id,
      name: membership.user.name,
      email: membership.user.email,
      role: to_string(membership.role),
      joined_at: DateTime.to_iso8601(membership.inserted_at)
    }
  end
end

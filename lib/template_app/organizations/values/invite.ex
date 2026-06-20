defmodule TemplateApp.Organizations.Values.Invite do
  @moduledoc """
  Builds invitation payloads for web responses
  """

  @doc @moduledoc
  def build(invitations) when is_list(invitations) do
    Enum.map(invitations, &build/1)
  end

  def build(invitation) do
    %{
      id: invitation.id,
      email: invitation.email,
      role: to_string(invitation.role),
      status: to_string(invitation.status),
      expires_at: format_datetime(invitation.expires_at),
      inserted_at: format_datetime(invitation.inserted_at),
      invited_by_email: invitation.inviter && invitation.inviter.email
    }
  end

  defp format_datetime(%DateTime{} = value), do: DateTime.to_iso8601(value)
  defp format_datetime(_), do: nil
end

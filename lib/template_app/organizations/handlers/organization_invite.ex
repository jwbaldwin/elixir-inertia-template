defmodule TemplateApp.Organizations.Handlers.OrganizationInvite do
  @moduledoc """
  Handles invite landing and acceptance state
  """

  alias TemplateApp.Accounts.Scope
  alias TemplateApp.Invitations
  alias TemplateApp.Organizations.Services.AcceptOrganizationInvitation
  alias TemplateApp.Organizations.Values.Invite

  @type invite_state ::
          :ready | :needs_login | :email_mismatch | :expired | :closed | :invalid | :unconfirmed

  @doc """
  Resolves invite display payload for token
  """
  @spec show(Scope.t() | nil, String.t()) :: {:ok, %{state: invite_state(), invitation: map() | nil}}
  def show(scope, token) when is_binary(token) do
    case Invitations.find_organization_invitation_by_token(token) do
      {:ok, invitation} ->
        {:ok, %{state: invite_state(scope, invitation), invitation: Invite.build(invitation)}}

      {:error, :not_found} ->
        {:ok, %{state: :invalid, invitation: nil}}
    end
  end

  @doc """
  Accepts invite token for current scope
  """
  @spec accept(Scope.t() | nil, String.t()) :: {:ok, map()} | {:error, term()}
  def accept(scope, token), do: AcceptOrganizationInvitation.call(scope, token)

  defp invite_state(_scope, %{status: status}) when status != :pending, do: :closed

  defp invite_state(scope, invitation) do
    if expired?(invitation.expires_at) do
      :expired
    else
      invite_state_for_user(scope, invitation.email)
    end
  end

  defp invite_state_for_user(%Scope{user: nil}, _invited_email), do: :needs_login

  defp invite_state_for_user(%Scope{user: user}, invited_email) do
    cond do
      normalize_email(user.email) != normalize_email(invited_email) -> :email_mismatch
      is_nil(user.confirmed_at) -> :unconfirmed
      true -> :ready
    end
  end

  defp invite_state_for_user(_scope, _invited_email), do: :needs_login

  defp normalize_email(value) when is_binary(value), do: value |> String.trim() |> String.downcase()
  defp normalize_email(_), do: ""

  defp expired?(%DateTime{} = expires_at), do: not DateTime.after?(expires_at, DateTime.utc_now(:second))
  defp expired?(_), do: true
end

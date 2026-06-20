defmodule TemplateApp.Organizations.Services.AcceptOrganizationInvitation do
  @moduledoc """
  Accepts an invitation and creates organization membership
  """

  alias TemplateApp.Accounts.Invitation
  alias TemplateApp.Accounts.Scope
  alias TemplateApp.Accounts.User
  alias TemplateApp.Invitations
  alias TemplateApp.Memberships

  @doc """
  Accepts a pending invitation for the current user
  """
  @spec call(Scope.t() | nil, String.t()) :: {:ok, map()} | {:error, term()}
  def call(%Scope{user: %User{} = user}, token) when is_binary(token) do
    with {:ok, invitation} <- Invitations.find_organization_invitation_by_token(token),
         :ok <- validate_invitation_for_user(invitation, user),
         {:ok, _membership} <-
           Memberships.ensure_membership(invitation.organization_id, user.id, invitation.role) do
      Invitations.update_organization_invitation_status(invitation, :accepted)
    end
  end

  def call(_scope, _token), do: {:error, :forbidden}

  defp validate_invitation_for_user(%Invitation{} = invitation, %User{} = user) do
    cond do
      invitation.status != :pending ->
        {:error, :invalid_status}

      not DateTime.after?(invitation.expires_at, DateTime.utc_now(:second)) ->
        {:error, :expired}

      normalize_email(invitation.email) != normalize_email(user.email) ->
        {:error, :email_mismatch}

      is_nil(user.confirmed_at) ->
        {:error, :unconfirmed_user}

      true ->
        :ok
    end
  end

  defp normalize_email(value) when is_binary(value), do: value |> String.trim() |> String.downcase()
  defp normalize_email(_), do: ""
end

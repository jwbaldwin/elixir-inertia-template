defmodule TemplateApp.Organizations.Services.CreateOrganizationInvitation do
  @moduledoc """
  Creates an invitation for the active organization
  """

  alias TemplateApp.Accounts.Scope
  alias TemplateApp.Accounts.UserNotifier
  alias TemplateApp.Invitations
  alias TemplateApp.Memberships

  @token_size 32
  @token_expiry_in_days 7

  @doc """
  Creates an invitation and sends it by email
  """
  @spec call(Scope.t() | nil, map(), (String.t() -> String.t())) ::
          {:ok, map()} | {:error, term()}
  def call(%Scope{user: user, organization: organization}, attrs, invite_url_fun)
      when is_map(attrs) and is_function(invite_url_fun, 1) do
    with email when is_binary(email) <- normalize_email(attrs),
         false <- Memberships.member_exists_for_email?(organization.id, email),
         {encoded_token, token_hash} <- build_token_pair(),
         :ok <- Invitations.cancel_pending_organization_invitations(organization.id, email),
         {:ok, invitation} <-
           Invitations.create_organization_invitation(%{
             organization_id: organization.id,
             inviter_user_id: user.id,
             email: email,
             role: extract_role(attrs),
             status: :pending,
             token_hash: token_hash,
             expires_at: DateTime.add(DateTime.utc_now(:second), @token_expiry_in_days * 24 * 60 * 60, :second)
           }),
         {:ok, _email} <-
           UserNotifier.deliver_organization_invitation(
             email,
             invite_url_fun.(encoded_token),
             organization.name,
             user.email,
             invitation.role
           ) do
      {:ok, invitation}
    else
      nil -> {:error, :invalid_email}
      true -> {:error, :already_member}
      {:error, reason} -> {:error, reason}
    end
  end

  def call(%Scope{}, _attrs, _invite_url_fun), do: {:error, :no_active_organization}
  def call(_scope, _attrs, _invite_url_fun), do: {:error, :forbidden}

  defp build_token_pair do
    token = :crypto.strong_rand_bytes(@token_size)
    {Base.url_encode64(token, padding: false), :crypto.hash(:sha256, token)}
  end

  defp normalize_email(attrs) do
    attrs
    |> extract_email()
    |> case do
      nil -> nil
      email -> email |> String.trim() |> String.downcase()
    end
    |> case do
      "" -> nil
      email -> email
    end
  end

  # Invitations accept string-keyed form params and atom-keyed Ecto attributes.
  # credo:disable-for-next-line ExSlop.Check.Warning.DualKeyAccess
  defp extract_email(attrs), do: Map.get(attrs, "email") || Map.get(attrs, :email)

  defp extract_role(attrs) do
    # Preserve the same attribute contract as extract_email/1.
    # credo:disable-for-next-line ExSlop.Check.Warning.DualKeyAccess
    role = Map.get(attrs, "role") || Map.get(attrs, :role)

    case role do
      :admin -> :admin
      "admin" -> :admin
      :member -> :member
      "member" -> :member
      _ -> :member
    end
  end
end

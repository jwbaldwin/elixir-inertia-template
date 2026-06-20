defmodule TemplateApp.Organizations.Handlers.OrganizationSettings do
  @moduledoc """
  Handles organization settings invitation workflows
  """

  alias TemplateApp.Accounts.Scope
  alias TemplateApp.Invitations
  alias TemplateApp.Memberships
  alias TemplateApp.Organizations.Services.CancelOrganizationInvitation
  alias TemplateApp.Organizations.Services.CreateOrganizationInvitation
  alias TemplateApp.Organizations.Services.RemoveOrganizationMember
  alias TemplateApp.Organizations.Values.Invite
  alias TemplateApp.Organizations.Values.Member
  alias TemplateApp.Organizations.Values.Organization

  @doc """
  Loads organization settings payload
  """
  @spec load_settings(Scope.t(), map()) :: {:ok, map()} | {:error, :no_active_organization}
  def load_settings(scope, invitation_form_params \\ %{})

  def load_settings(%Scope{organization: nil}, _invitation_form_params), do: {:error, :no_active_organization}

  def load_settings(%Scope{organization: organization}, invitation_form_params) when not is_nil(organization) do
    invitations = Invitations.list_pending_organization_invitations(organization.id)
    memberships = Memberships.list_organization_members(organization.id)

    {:ok,
     %{
       organization: Organization.build(organization),
       invitations: Invite.build(invitations),
       members: Member.build(memberships),
       form: invitation_form(invitation_form_params)
     }}
  end

  @doc """
  Creates an organization invitation
  """
  @spec create_invitation(Scope.t(), map(), (String.t() -> String.t())) ::
          {:ok, map()} | {:error, term()}
  def create_invitation(%Scope{} = scope, invitation_params, invite_url_fun) do
    CreateOrganizationInvitation.call(scope, invitation_params, invite_url_fun)
  end

  @doc """
  Cancels a pending organization invitation
  """
  @spec cancel_invitation(Scope.t(), integer() | String.t()) :: {:ok, map()} | {:error, term()}
  def cancel_invitation(%Scope{organization: organization}, invitation_id) do
    with {:ok, invitation} <-
           Invitations.find_pending_organization_invitation(organization.id, invitation_id) do
      CancelOrganizationInvitation.call(invitation)
    end
  end

  @doc """
  Updates the active organization name
  """
  @spec update_organization_name(Scope.t(), %{name: String.t()}) ::
          {:ok, TemplateApp.Accounts.Organization.t()} | {:error, Ecto.Changeset.t()}
  def update_organization_name(%Scope{organization: organization}, %{"name" => name}) do
    TemplateApp.Organizations.update_organization(organization, %{name: String.trim(name)})
  end

  @doc """
  Removes a member from the active organization
  """
  @spec remove_member(Scope.t(), integer()) ::
          {:ok, TemplateApp.Accounts.Membership.t()} | {:error, :cannot_remove_self | :not_found | Ecto.Changeset.t()}
  def remove_member(%Scope{} = scope, membership_id) do
    RemoveOrganizationMember.call(scope, membership_id)
  end

  defp invitation_form(invitation_params) do
    %{
      "email" => invitation_form_value(invitation_params, "email"),
      "role" => invitation_form_role(invitation_params)
    }
  end

  defp invitation_form_role(invitation_params) do
    case invitation_form_value(invitation_params, "role") do
      "admin" -> "admin"
      _ -> "member"
    end
  end

  defp invitation_form_value(invitation_params, key) do
    case Map.get(invitation_params, key) do
      value when is_binary(value) -> value
      _ -> ""
    end
  end
end

defmodule TemplateApp.Authorization do
  @moduledoc """
  Authorization policies for TemplateApp domains

  This module is an explicit taxonomy exception because authorization is a cross-cutting concern
  """

  @behaviour Bodyguard.Policy

  alias TemplateApp.Accounts.Organization
  alias TemplateApp.Accounts.Scope
  alias TemplateApp.Memberships

  @type action :: :can_view | :can_edit
  @type reason :: :forbidden | :no_active_organization

  ###
  # Convenience helpers
  ###

  @doc """
  Runs authorization for an action using the scope's active organization
  """
  @spec permit(Scope.t() | nil, action()) :: :ok | {:error, reason()}
  def permit(%Scope{} = scope, action) do
    Bodyguard.permit(__MODULE__, action, scope, scope.organization)
  end

  def permit(_scope, _action), do: {:error, :forbidden}

  @doc """
  Returns true when the scope can edit its active organization (useful for props)
  """
  @spec can_edit?(Scope.t() | nil) :: boolean()
  def can_edit?(scope), do: permit(scope, :can_edit) == :ok

  @doc """
  Returns true when the scope can view its active organization (useful for props)
  """
  @spec can_view?(Scope.t() | nil) :: boolean()
  def can_view?(scope), do: permit(scope, :can_view) == :ok

  ###
  # Actual Bodyguard.Policy callbacks
  ###

  @doc """
  Authorizes organization capabilities
  """
  @spec authorize(action(), Scope.t() | nil, Organization.t() | nil) :: :ok | {:error, reason()}
  def authorize(:can_view, %Scope{user: user}, %Organization{id: org_id}) when not is_nil(user) do
    case Memberships.find_membership_by(%{org_id: org_id, user_id: user.id}) do
      {:ok, _membership} -> :ok
      {:error, :not_found} -> {:error, :forbidden}
    end
  end

  def authorize(:can_edit, %Scope{user: user}, %Organization{id: org_id}) when not is_nil(user) do
    with {:ok, membership} <- Memberships.find_membership_by(%{org_id: org_id, user_id: user.id}),
         true <- membership.role in [:owner, :admin] do
      :ok
    else
      false -> {:error, :forbidden}
      {:error, :not_found} -> {:error, :forbidden}
    end
  end

  def authorize(_action, %Scope{organization: nil}, _organization), do: {:error, :no_active_organization}
  def authorize(_action, _scope, _organization), do: {:error, :forbidden}
end

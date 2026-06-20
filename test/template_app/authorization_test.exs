defmodule TemplateApp.AuthorizationTest do
  use TemplateApp.DataCase, async: true

  alias TemplateApp.Accounts.Scope
  alias TemplateApp.Authorization

  describe "authorize/3" do
    test "allows organization members to view" do
      user = insert(:user)
      organization = insert(:organization)
      _membership = insert(:membership, user: user, organization: organization, role: :member)

      scope = %Scope{user: user, organization: organization}

      assert :ok = Authorization.authorize(:can_view, scope, organization)
    end

    test "allows admins to edit" do
      user = insert(:user)
      organization = insert(:organization)
      _membership = insert(:membership, user: user, organization: organization, role: :admin)

      scope = %Scope{user: user, organization: organization}

      assert :ok = Authorization.authorize(:can_edit, scope, organization)
    end

    test "forbids members from editing" do
      user = insert(:user)
      organization = insert(:organization)
      _membership = insert(:membership, user: user, organization: organization, role: :member)

      scope = %Scope{user: user, organization: organization}

      assert {:error, :forbidden} = Authorization.authorize(:can_edit, scope, organization)
    end

    test "returns no_active_organization when scope has no active organization" do
      user = insert(:user)

      scope = %Scope{user: user, organization: nil}

      assert {:error, :no_active_organization} = Authorization.authorize(:can_view, scope, nil)
    end
  end
end

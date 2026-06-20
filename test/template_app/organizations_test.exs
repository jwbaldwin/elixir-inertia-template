defmodule TemplateApp.OrganizationsTest do
  use TemplateApp.DataCase, async: true

  alias TemplateApp.Organizations

  describe "fetch_first_organization_by_user/1" do
    test "returns the user's organizations by deterministic name order" do
      user = insert(:user)
      later_organization = insert(:organization, name: "Zebra Studio", slug: "zebra-studio")
      first_organization = insert(:organization, name: "Acme Studio", slug: "acme-studio")

      insert(:membership, user: user, organization: later_organization)
      insert(:membership, user: user, organization: first_organization)

      assert {:ok, organization} = Organizations.fetch_first_organization_by_user(user)
      assert organization.id == first_organization.id
    end
  end

  describe "list_organizations_by_user/1" do
    test "returns only the user's organizations by name" do
      user = insert(:user)
      beta_organization = insert(:organization, name: "Beta Studio", slug: "beta-studio")
      alpha_organization = insert(:organization, name: "Alpha Studio", slug: "alpha-studio")
      _other_organization = insert(:organization, name: "Other Studio", slug: "other-studio")

      insert(:membership, user: user, organization: beta_organization)
      insert(:membership, user: user, organization: alpha_organization)

      assert Organizations.list_organizations_by_user(user) == [alpha_organization, beta_organization]
    end
  end
end

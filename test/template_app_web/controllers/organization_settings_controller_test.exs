defmodule TemplateAppWeb.OrganizationSettingsControllerTest do
  use TemplateAppWeb.ConnCase, async: true

  import Inertia.Testing

  alias TemplateApp.Accounts.Invitation
  alias TemplateApp.Accounts.Membership
  alias TemplateApp.Accounts.Organization
  alias TemplateApp.Repo

  describe "GET /org/settings" do
    test "returns can_edit false for member role", %{conn: conn} do
      member_user = insert(:user)
      organization = insert(:organization)
      insert(:membership, user: member_user, organization: organization, role: :member)

      conn =
        conn
        |> log_in_user(member_user)
        |> put_session(:active_organization_id, organization.id)
        |> get(~p"/org/settings")

      assert inertia_component(conn) == "app/settings/organization"
      assert inertia_props(conn).can_edit == false
    end

    test "returns can_edit true for admin role", %{conn: conn} do
      admin_user = insert(:user)
      organization = insert(:organization)
      insert(:membership, user: admin_user, organization: organization, role: :admin)

      conn =
        conn
        |> log_in_user(admin_user)
        |> put_session(:active_organization_id, organization.id)
        |> get(~p"/org/settings")

      assert inertia_component(conn) == "app/settings/organization"
      assert inertia_props(conn).can_edit == true
    end
  end

  describe "PUT /org/settings" do
    test "updates organization name for admin role", %{conn: conn} do
      admin_user = insert(:user)
      organization = insert(:organization, name: "Before Name")
      insert(:membership, user: admin_user, organization: organization, role: :admin)

      conn =
        conn
        |> log_in_user(admin_user)
        |> put_session(:active_organization_id, organization.id)
        |> put(~p"/org/settings", %{"organization" => %{"name" => "After Name"}})

      assert redirected_to(conn) == ~p"/org/settings"
      assert Repo.get!(Organization, organization.id).name == "After Name"
    end

    test "does not update organization name for member role", %{conn: conn} do
      member_user = insert(:user)
      organization = insert(:organization, name: "Original Name")
      insert(:membership, user: member_user, organization: organization, role: :member)

      conn =
        conn
        |> log_in_user(member_user)
        |> put_session(:active_organization_id, organization.id)
        |> put(~p"/org/settings", %{"organization" => %{"name" => "Blocked Name"}})

      assert redirected_to(conn) == ~p"/"
      assert Repo.get!(Organization, organization.id).name == "Original Name"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "You do not have permission to perform this action."
    end

    test "returns name error when organization name is blank", %{conn: conn} do
      admin_user = insert(:user)
      organization = insert(:organization)
      insert(:membership, user: admin_user, organization: organization, role: :admin)

      conn =
        conn
        |> log_in_user(admin_user)
        |> put_session(:active_organization_id, organization.id)
        |> put(~p"/org/settings", %{"organization" => %{"name" => "   "}})

      assert conn.status == 422
      assert inertia_component(conn) == "app/settings/organization"
      assert inertia_errors(conn)[:name] == "can't be blank"
    end
  end

  describe "POST /org/settings/invitations" do
    test "creates pending invitation for admin role", %{conn: conn} do
      admin_user = insert(:user)
      organization = insert(:organization)
      insert(:membership, user: admin_user, organization: organization, role: :admin)

      conn =
        conn
        |> log_in_user(admin_user)
        |> put_session(:active_organization_id, organization.id)
        |> post(~p"/org/settings/invitations", %{
          "invitation" => %{"email" => "new-member@example.com", "role" => "admin"}
        })

      assert redirected_to(conn) == ~p"/org/settings"

      assert %Invitation{} =
               Repo.get_by!(Invitation,
                 organization_id: organization.id,
                 inviter_user_id: admin_user.id,
                 email: "new-member@example.com",
                 role: :admin,
                 status: :pending
               )
    end

    test "does not create invitation for member role", %{conn: conn} do
      member_user = insert(:user)
      organization = insert(:organization)
      insert(:membership, user: member_user, organization: organization, role: :member)

      conn =
        conn
        |> log_in_user(member_user)
        |> put_session(:active_organization_id, organization.id)
        |> post(~p"/org/settings/invitations", %{
          "invitation" => %{"email" => "blocked@example.com", "role" => "member"}
        })

      assert redirected_to(conn) == ~p"/"

      refute Repo.get_by(Invitation,
               organization_id: organization.id,
               email: "blocked@example.com",
               status: :pending
             )
    end

    test "returns email error when invited email already belongs to member", %{conn: conn} do
      admin_user = insert(:user)
      organization = insert(:organization)
      insert(:membership, user: admin_user, organization: organization, role: :admin)

      existing_member_user = insert(:user, email: "existing@example.com")
      insert(:membership, user: existing_member_user, organization: organization, role: :member)

      conn =
        conn
        |> log_in_user(admin_user)
        |> put_session(:active_organization_id, organization.id)
        |> post(~p"/org/settings/invitations", %{
          "invitation" => %{"email" => "existing@example.com", "role" => "member"}
        })

      assert conn.status == 422
      assert inertia_component(conn) == "app/settings/organization"
      assert inertia_errors(conn)[:email] == "That user is already a member of this organization."
    end
  end

  describe "DELETE /org/settings/invitations/:invitation_id" do
    test "cancels pending invitation for admin role", %{conn: conn} do
      admin_user = insert(:user)
      organization = insert(:organization)
      insert(:membership, user: admin_user, organization: organization, role: :admin)

      invitation =
        insert(:invitation,
          organization: organization,
          inviter: admin_user,
          status: :pending,
          email: "pending@example.com"
        )

      conn =
        conn
        |> log_in_user(admin_user)
        |> put_session(:active_organization_id, organization.id)
        |> delete(~p"/org/settings/invitations/#{invitation.id}")

      assert redirected_to(conn) == ~p"/org/settings"
      assert Repo.get!(Invitation, invitation.id).status == :cancelled
    end
  end

  describe "DELETE /org/settings/members/:membership_id" do
    test "removes selected member for admin role", %{conn: conn} do
      admin_user = insert(:user)
      organization = insert(:organization)
      insert(:membership, user: admin_user, organization: organization, role: :admin)

      member_to_remove = insert(:user)

      member_to_remove_membership =
        insert(:membership, user: member_to_remove, organization: organization, role: :member)

      conn =
        conn
        |> log_in_user(admin_user)
        |> put_session(:active_organization_id, organization.id)
        |> delete(~p"/org/settings/members/#{member_to_remove_membership.id}")

      assert redirected_to(conn) == ~p"/org/settings"
      refute Repo.get(Membership, member_to_remove_membership.id)
    end

    test "keeps membership when admin tries to remove self", %{conn: conn} do
      admin_user = insert(:user)
      organization = insert(:organization)

      admin_membership =
        insert(:membership, user: admin_user, organization: organization, role: :admin)

      conn =
        conn
        |> log_in_user(admin_user)
        |> put_session(:active_organization_id, organization.id)
        |> delete(~p"/org/settings/members/#{admin_membership.id}")

      assert redirected_to(conn) == ~p"/org/settings"
      assert Repo.get(Membership, admin_membership.id)
    end

    test "keeps membership when member role tries to remove another member", %{conn: conn} do
      member_actor = insert(:user)
      organization = insert(:organization)
      insert(:membership, user: member_actor, organization: organization, role: :member)

      other_member = insert(:user)
      other_member_membership = insert(:membership, user: other_member, organization: organization)

      conn =
        conn
        |> log_in_user(member_actor)
        |> put_session(:active_organization_id, organization.id)
        |> delete(~p"/org/settings/members/#{other_member_membership.id}")

      assert redirected_to(conn) == ~p"/"
      assert Repo.get(Membership, other_member_membership.id)
    end

    test "returns not found when membership id is not an integer", %{conn: conn} do
      admin_user = insert(:user)
      organization = insert(:organization)
      insert(:membership, user: admin_user, organization: organization, role: :admin)

      conn =
        conn
        |> log_in_user(admin_user)
        |> put_session(:active_organization_id, organization.id)
        |> delete(~p"/org/settings/members/not-a-number")

      assert redirected_to(conn) == ~p"/org/settings"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Member not found"
    end
  end
end

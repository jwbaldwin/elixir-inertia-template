defmodule TemplateAppWeb.OrganizationInvitationControllerTest do
  use TemplateAppWeb.ConnCase, async: true

  import Inertia.Testing

  alias TemplateApp.Accounts.Invitation
  alias TemplateApp.Accounts.Membership
  alias TemplateApp.Repo

  describe "GET /org/invites/:token" do
    test "renders invitation page for unauthenticated user", %{conn: conn} do
      invitation = insert(:invitation, status: :pending)
      {token, _invitation} = generate_organization_invitation_token(invitation)

      conn = get(conn, ~p"/org/invites/#{token}")

      assert inertia_component(conn) == "public/organization-invite"
      assert inertia_props(conn).state == "needs_login"
      assert inertia_props(conn).invitation.email == invitation.email
      assert inertia_props(conn).login_url == "/login?return_to=%2Forg%2Finvites%2F#{token}"
    end

    test "renders invalid state for unknown token", %{conn: conn} do
      conn = get(conn, ~p"/org/invites/invalid-token")

      assert inertia_component(conn) == "public/organization-invite"
      assert inertia_props(conn).state == "invalid"
      assert is_nil(inertia_props(conn).invitation)
    end
  end

  describe "POST /org/invites/:token/accept" do
    test "accepts invitation and creates membership", %{conn: conn} do
      organization = insert(:organization)
      inviter = insert(:user)
      _inviter_membership = insert(:membership, user: inviter, organization: organization, role: :owner)

      invitee = insert(:user, email: "invitee@example.com")

      invitation =
        insert(:invitation,
          organization: organization,
          inviter: inviter,
          email: invitee.email,
          role: :admin,
          status: :pending
        )

      {token, invitation} = generate_organization_invitation_token(invitation)

      conn =
        conn
        |> log_in_user(invitee)
        |> post(~p"/org/invites/#{token}/accept")

      assert redirected_to(conn) == ~p"/"
      assert get_session(conn, :active_organization_id) == organization.id

      assert %Membership{role: :admin} =
               Repo.get_by!(Membership, organization_id: organization.id, user_id: invitee.id)

      assert Repo.get!(Invitation, invitation.id).status == :accepted
    end

    test "rejects acceptance when signed-in email does not match", %{conn: conn} do
      organization = insert(:organization)
      inviter = insert(:user)
      _inviter_membership = insert(:membership, user: inviter, organization: organization, role: :owner)

      invitation =
        insert(:invitation,
          organization: organization,
          inviter: inviter,
          email: "invitee@example.com",
          status: :pending
        )

      {token, invitation} = generate_organization_invitation_token(invitation)
      other_user = insert(:user, email: "someone-else@example.com")

      conn =
        conn
        |> log_in_user(other_user)
        |> post(~p"/org/invites/#{token}/accept")

      assert redirected_to(conn) == ~p"/org/invites/#{token}"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "This invitation was sent to a different email address"

      refute Repo.get_by(Membership, organization_id: organization.id, user_id: other_user.id)
      assert Repo.get!(Invitation, invitation.id).status == :pending
    end
  end
end

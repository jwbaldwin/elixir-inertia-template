defmodule TemplateApp.AccountsTest do
  use TemplateApp.DataCase

  alias Ecto.Adapters.SQL
  alias TemplateApp.Accounts
  alias TemplateApp.Accounts.Invitation
  alias TemplateApp.Accounts.Membership
  alias TemplateApp.Accounts.Organization
  alias TemplateApp.Accounts.User
  alias TemplateApp.Accounts.UserToken
  alias TemplateApp.Organizations

  describe "get_user_by_email/1" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email("unknown@example.com")
    end

    test "returns the user if the email exists" do
      %{id: id} = user = insert(:user)
      assert %User{id: ^id} = Accounts.get_user_by_email(user.email)
    end
  end

  describe "get_user_by_email_and_password/2" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the user if the password is not valid" do
      user = set_password(insert(:user))
      refute Accounts.get_user_by_email_and_password(user.email, "invalid")
    end

    test "returns the user if the email and password are valid" do
      %{id: id} = user = set_password(insert(:user))

      assert %User{id: ^id} =
               Accounts.get_user_by_email_and_password(user.email, valid_user_password())
    end
  end

  describe "get_user!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(-1)
      end
    end

    test "returns the user with the given id" do
      %{id: id} = user = insert(:user)
      assert %User{id: ^id} = Accounts.get_user!(user.id)
    end
  end

  describe "register_user/1" do
    defp valid_registration_attrs do
      params_for(:registration_attrs)
    end

    test "requires name to be set" do
      registration_attrs = Map.delete(valid_registration_attrs(), :name)

      {:error, changeset} = Accounts.register_user(registration_attrs)

      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "requires email to be set" do
      registration_attrs = Map.delete(valid_registration_attrs(), :email)

      {:error, changeset} = Accounts.register_user(registration_attrs)

      assert %{email: ["can't be blank"]} = errors_on(changeset)
    end

    test "requires password to be set" do
      registration_attrs = Map.delete(valid_registration_attrs(), :password)

      {:error, changeset} = Accounts.register_user(registration_attrs)

      assert %{password: ["can't be blank"]} = errors_on(changeset)
    end

    test "validates email when given" do
      registration_attrs = valid_registration_attrs()

      {:error, changeset} =
        Accounts.register_user(%{registration_attrs | email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum values for email for security" do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        valid_registration_attrs()
        |> Map.put(:email, too_long)
        |> Accounts.register_user()

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates minimum password length" do
      registration_attrs =
        valid_registration_attrs()
        |> Map.put(:password, "too short")
        |> Map.put(:password_confirmation, "too short")

      {:error, changeset} = Accounts.register_user(registration_attrs)

      assert "should be at least 12 character(s)" in errors_on(changeset).password
    end

    test "validates password confirmation" do
      registration_attrs = Map.put(valid_registration_attrs(), :password_confirmation, "different password")

      {:error, changeset} = Accounts.register_user(registration_attrs)

      assert "does not match password" in errors_on(changeset).password_confirmation
    end

    test "validates email uniqueness" do
      %{email: email} = insert(:user)

      {:error, changeset} =
        valid_registration_attrs()
        |> Map.put(:email, email)
        |> Accounts.register_user()

      assert "has already been taken" in errors_on(changeset).email

      # Now try with the uppercased email too, to check that email case is ignored.
      {:error, changeset} =
        valid_registration_attrs()
        |> Map.put(:email, String.upcase(email))
        |> Accounts.register_user()

      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers users with password" do
      registration_attrs = params_for(:registration_attrs)

      {:ok, user} = Accounts.register_user(registration_attrs)

      assert user.name == registration_attrs.name
      assert user.email == registration_attrs.email
      assert User.valid_password?(user, registration_attrs.password)
      assert is_nil(user.confirmed_at)
      assert is_nil(user.password)
    end

    test "registers an organization and owner membership" do
      company_name = "Acme Studio"
      registration_attrs = params_for(:registration_attrs, company_name: company_name)

      {:ok, user} = Accounts.register_user(registration_attrs)

      membership = Repo.get_by!(Membership, user_id: user.id)
      organization = Repo.get!(Organization, membership.organization_id)

      assert membership.role == :owner
      assert organization.name == company_name
      assert organization.slug == "acme-studio"
    end
  end

  describe "Organizations.fetch_active_organization_by_user/2" do
    setup do
      %{user: insert(:user)}
    end

    test "returns preferred organization when membership exists", %{user: user} do
      organization = insert(:organization)
      _membership = insert(:membership, user: user, organization: organization, role: :admin)

      assert {:ok, resolved_organization} =
               Organizations.fetch_active_organization_by_user(user, organization.id)

      assert resolved_organization.id == organization.id
    end
  end

  describe "organization auth constraints" do
    test "enforces organization slug uniqueness" do
      slug = params_for(:organization).slug
      _organization = insert(:organization, slug: slug)

      assert {:error, changeset} =
               %Organization{}
               |> Organization.changeset(%{name: "Another Organization", slug: slug})
               |> Repo.insert()

      assert "has already been taken" in errors_on(changeset).slug
    end

    test "enforces unique membership per organization/user pair" do
      user = insert(:user)
      organization = insert(:organization)
      _membership = insert(:membership, user: user, organization: organization)

      assert {:error, changeset} =
               %Membership{}
               |> Membership.changeset(%{
                 organization_id: organization.id,
                 user_id: user.id,
                 role: :member
               })
               |> Repo.insert()

      assert "has already been taken" in errors_on(changeset).organization_id
    end

    test "enforces membership role check constraint" do
      user = insert(:user)
      organization = insert(:organization)

      assert_raise Postgrex.Error, ~r/memberships_role_check/, fn ->
        SQL.query!(
          Repo,
          """
          INSERT INTO memberships (organization_id, user_id, role, inserted_at, updated_at)
          VALUES ($1, $2, $3, NOW(), NOW())
          """,
          [organization.id, user.id, "invalid"]
        )
      end
    end

    test "enforces invitation token_hash uniqueness" do
      inviter_user = insert(:user)
      organization = insert(:organization)
      token_hash = :crypto.strong_rand_bytes(32)
      invitation_email = params_for(:registration_attrs).email

      _invitation = insert(:invitation, inviter: inviter_user, organization: organization, token_hash: token_hash)

      assert {:error, changeset} =
               %Invitation{}
               |> Invitation.changeset(%{
                 organization_id: organization.id,
                 email: invitation_email,
                 role: :member,
                 inviter_user_id: inviter_user.id,
                 status: :pending,
                 token_hash: token_hash,
                 expires_at: DateTime.utc_now(:second)
               })
               |> Repo.insert()

      assert "has already been taken" in errors_on(changeset).token_hash
    end

    test "enforces invitation status check constraint" do
      inviter_user = insert(:user)
      organization = insert(:organization)

      assert_raise Postgrex.Error, ~r/invitations_status_check/, fn ->
        SQL.query!(
          Repo,
          """
          INSERT INTO invitations
            (organization_id, email, role, inviter_user_id, status, token_hash, expires_at, inserted_at, updated_at)
          VALUES
            ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW())
          """,
          [
            organization.id,
            params_for(:registration_attrs).email,
            "member",
            inviter_user.id,
            "bad-status",
            :crypto.strong_rand_bytes(32),
            DateTime.utc_now(:second)
          ]
        )
      end
    end

    test "enforces invitation organization foreign key" do
      inviter_user = insert(:user)

      invitation_attrs = %{
        organization_id: -1,
        email: params_for(:registration_attrs).email,
        role: :member,
        inviter_user_id: inviter_user.id,
        status: :pending,
        token_hash: :crypto.strong_rand_bytes(32),
        expires_at: DateTime.utc_now(:second)
      }

      assert {:error, missing_org_changeset} =
               %Invitation{}
               |> Invitation.changeset(invitation_attrs)
               |> Repo.insert()

      assert "does not exist" in errors_on(missing_org_changeset).organization_id
    end

    test "enforces invitation inviter foreign key" do
      organization = insert(:organization)

      invitation_attrs = %{
        organization_id: organization.id,
        email: params_for(:registration_attrs).email,
        role: :member,
        inviter_user_id: -1,
        status: :pending,
        token_hash: :crypto.strong_rand_bytes(32),
        expires_at: DateTime.utc_now(:second)
      }

      assert {:error, missing_inviter_changeset} =
               %Invitation{}
               |> Invitation.changeset(invitation_attrs)
               |> Repo.insert()

      assert "does not exist" in errors_on(missing_inviter_changeset).inviter_user_id
    end
  end

  describe "sudo_mode?/2" do
    test "validates the authenticated_at time" do
      now = DateTime.utc_now()

      assert Accounts.sudo_mode?(%User{authenticated_at: DateTime.utc_now()})
      assert Accounts.sudo_mode?(%User{authenticated_at: DateTime.add(now, -19, :minute)})
      refute Accounts.sudo_mode?(%User{authenticated_at: DateTime.add(now, -21, :minute)})

      # minute override
      refute Accounts.sudo_mode?(
               %User{authenticated_at: DateTime.add(now, -11, :minute)},
               -10
             )

      # not authenticated
      refute Accounts.sudo_mode?(%User{})
    end
  end

  describe "change_user_email/3" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_email(%User{})
      assert changeset.required == [:email]
    end
  end

  describe "deliver_user_update_email_instructions/3" do
    setup do
      %{user: insert(:user)}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_update_email_instructions(user, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "change:current@example.com"
    end
  end

  describe "update_user_email/2" do
    setup do
      user = insert(:unconfirmed_user)
      email = params_for(:registration_attrs).email

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{user: user, token: token, email: email}
    end

    test "updates the email with a valid token", %{user: user, token: token, email: email} do
      assert {:ok, %{email: ^email}} = Accounts.update_user_email(user, token)
      changed_user = Repo.get!(User, user.id)
      assert changed_user.email != user.email
      assert changed_user.email == email
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email with invalid token", %{user: user} do
      assert Accounts.update_user_email(user, "oops") ==
               {:error, :transaction_aborted}

      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if user email changed", %{user: user, token: token} do
      assert Accounts.update_user_email(%{user | email: "current@example.com"}, token) ==
               {:error, :transaction_aborted}

      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])

      assert Accounts.update_user_email(user, token) ==
               {:error, :transaction_aborted}

      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "change_user_password/3" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_password(%User{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Accounts.change_user_password(
          %User{},
          %{
            "password" => "new valid password"
          },
          hash_password: false
        )

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_user_password/2" do
    setup do
      %{user: insert(:user)}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.update_user_password(user, %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{user: user} do
      {:ok, {user, expired_tokens}} =
        Accounts.update_user_password(user, %{
          password: "new valid password"
        })

      assert expired_tokens == []
      assert is_nil(user.password)
      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Accounts.generate_user_session_token(user)

      {:ok, {_, _}} =
        Accounts.update_user_password(user, %{
          password: "new valid password"
        })

      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "generate_user_session_token/1" do
    setup do
      %{user: insert(:user)}
    end

    test "generates a token", %{user: user} do
      token = Accounts.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context == "session"
      assert user_token.authenticated_at

      # Creating the same token for another user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: insert(:user).id,
          context: "session"
        })
      end
    end

    test "duplicates the authenticated_at of given user in new token", %{user: user} do
      user = %{user | authenticated_at: DateTime.add(DateTime.utc_now(:second), -3600)}
      token = Accounts.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.authenticated_at == user.authenticated_at
      assert DateTime.after?(user_token.inserted_at, user.authenticated_at)
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = insert(:user)
      token = Accounts.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert {session_user, token_inserted_at} = Accounts.get_user_by_session_token(token)
      assert session_user.id == user.id
      assert session_user.authenticated_at
      assert token_inserted_at
    end

    test "does not return user for invalid token" do
      refute Accounts.get_user_by_session_token("oops")
    end

    test "does not return user for expired token", %{token: token} do
      dt = ~N[2020-01-01 00:00:00]
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: dt, authenticated_at: dt])
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "deliver_user_confirmation_instructions/2" do
    setup do
      %{user: insert(:unconfirmed_user)}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "confirm"
    end
  end

  describe "confirm_user/1" do
    setup do
      user = insert(:unconfirmed_user)

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      %{user: user, token: token}
    end

    test "confirms the user and removes tokens", %{user: user, token: token} do
      assert {:ok, confirmed_user} = Accounts.confirm_user(token)
      assert confirmed_user.confirmed_at
      assert Repo.get!(User, user.id).confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "returns error with invalid token" do
      assert :error == Accounts.confirm_user("oops")
    end

    test "returns error when token is expired", %{token: token} do
      {:ok, decoded_token} = Base.url_decode64(token, padding: false)
      hashed_token = :crypto.hash(:sha256, decoded_token)

      {1, nil} =
        Repo.update_all(
          from(user_token in UserToken, where: user_token.token == ^hashed_token),
          set: [inserted_at: ~N[2020-01-01 00:00:00]]
        )

      assert :error == Accounts.confirm_user(token)
      assert Repo.get_by(UserToken, token: hashed_token)
    end
  end

  describe "delete_user_session_token/1" do
    test "deletes the token" do
      user = insert(:user)
      token = Accounts.generate_user_session_token(user)
      assert Accounts.delete_user_session_token(token) == :ok
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "inspect/2 for the User module" do
    test "does not include password" do
      refute inspect(%User{password: "123456"}) =~ "password: \"123456\""
    end
  end
end

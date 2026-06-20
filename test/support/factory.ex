defmodule TemplateApp.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: TemplateApp.Repo

  alias TemplateApp.Accounts.Invitation
  alias TemplateApp.Accounts.Membership
  alias TemplateApp.Accounts.Organization
  alias TemplateApp.Accounts.User
  alias TemplateApp.Accounts.UserToken

  def user_factory do
    %User{
      name: sequence(:user_name, &"User #{&1}"),
      email: sequence(:user_email, &"user#{&1}@example.com"),
      confirmed_at: DateTime.utc_now(:second)
    }
  end

  def unconfirmed_user_factory do
    struct!(user_factory(), %{confirmed_at: nil})
  end

  def organization_factory do
    %Organization{
      name: sequence(:organization_name, &"Organization #{&1}"),
      slug: sequence(:organization_slug, &"org-#{&1}")
    }
  end

  def membership_factory do
    %Membership{
      role: :member,
      user: build(:user),
      organization: build(:organization)
    }
  end

  def invitation_factory do
    %Invitation{
      email: sequence(:invitation_email, &"invitee#{&1}@example.com"),
      role: :member,
      status: :pending,
      token_hash: sequence(:invitation_token_hash, &:crypto.hash(:sha256, "invitation-token-#{&1}")),
      expires_at: DateTime.add(DateTime.utc_now(:second), 7 * 24 * 60 * 60, :second),
      inviter: build(:user),
      organization: build(:organization)
    }
  end

  def user_token_factory do
    %UserToken{
      token: sequence(:user_token_hash, &:crypto.hash(:sha256, "session-token-#{&1}")),
      context: "session",
      sent_to: sequence(:user_token_email, &"token-user#{&1}@example.com"),
      authenticated_at: DateTime.utc_now(:second),
      user: build(:user)
    }
  end

  def registration_attrs_factory do
    %{
      name: sequence(:registration_name, &"Registration User #{&1}"),
      email: sequence(:registration_email, &"registration#{&1}@example.com"),
      company_name: sequence(:company_name, &"Company #{&1}"),
      password: "hello world!",
      password_confirmation: "hello world!"
    }
  end
end

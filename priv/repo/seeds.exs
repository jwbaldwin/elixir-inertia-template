# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

alias TemplateApp.Accounts
alias TemplateApp.Accounts.Membership
alias TemplateApp.Accounts.Organization
alias TemplateApp.Accounts.User
alias TemplateApp.Accounts.UserToken
alias TemplateApp.Repo

Repo.delete_all(Membership)
Repo.delete_all(UserToken)
Repo.delete_all(Organization)
Repo.delete_all(User)

password = "TestPassword123"

{:ok, user} =
  Accounts.register_user(%{
    name: "Demo User",
    email: "demo@example.com",
    password: password,
    password_confirmation: password,
    company_name: "Example Organization"
  })

user
|> Ecto.Changeset.change(confirmed_at: DateTime.utc_now(:second))
|> Repo.update!()

IO.puts("Seeded demo@example.com with password #{password}")

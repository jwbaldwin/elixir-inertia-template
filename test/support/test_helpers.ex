defmodule TemplateApp.TestHelpers do
  @moduledoc false

  import Ecto.Query

  alias TemplateApp.Accounts
  alias TemplateApp.Accounts.UserToken
  alias TemplateApp.Repo

  def valid_user_password, do: "hello world!"

  def set_password(user) do
    {:ok, {user, _expired_tokens}} =
      Accounts.update_user_password(user, %{password: valid_user_password()})

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  def override_token_authenticated_at(token, authenticated_at) when is_binary(token) do
    Repo.update_all(
      from(user_token in UserToken, where: user_token.token == ^token),
      set: [authenticated_at: authenticated_at]
    )
  end

  def offset_user_token(token, amount_to_add, unit) do
    offset_datetime = DateTime.add(DateTime.utc_now(:second), amount_to_add, unit)

    Repo.update_all(
      from(user_token in UserToken, where: user_token.token == ^token),
      set: [inserted_at: offset_datetime, authenticated_at: offset_datetime]
    )
  end

  def generate_organization_invitation_token(invitation) do
    token = :crypto.strong_rand_bytes(32)
    encoded_token = Base.url_encode64(token, padding: false)
    hashed_token = :crypto.hash(:sha256, token)

    invitation =
      invitation
      |> Ecto.Changeset.change(%{token_hash: hashed_token})
      |> Repo.update!()

    {encoded_token, invitation}
  end

  def clean_test_dir(path) do
    File.rm_rf!(path)
    File.mkdir_p!(path)

    ExUnit.Callbacks.on_exit(fn -> File.rm_rf!(path) end)

    path
  end

  def test_tmp_dir(prefix) do
    System.tmp_dir!()
    |> Path.join("#{prefix}-#{System.unique_integer([:positive])}")
    |> clean_test_dir()
  end

  def write_test_file(path, contents) do
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, contents)

    path
  end

  def write_test_file(dir, name, contents) do
    dir
    |> Path.join(name)
    |> write_test_file(contents)
  end
end

defmodule TemplateAppWeb.ConnCase do
  @moduledoc """
  Connection tests with factories, auth helpers, and SQL sandbox isolation
  """

  use Boundary, top_level?: true, check: [out: false]
  use ExUnit.CaseTemplate

  alias TemplateApp.Accounts.Scope

  using do
    quote do
      use TemplateAppWeb, :verified_routes

      import Phoenix.ConnTest
      import Plug.Conn
      import TemplateApp.Factory
      import TemplateApp.TestHelpers
      import TemplateAppWeb.ConnCase

      # The default endpoint for testing
      @endpoint TemplateAppWeb.Endpoint

      # Import conveniences for testing with connections
    end
  end

  setup tags do
    TemplateApp.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_log_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_user(%{conn: conn} = context) do
    user = TemplateApp.Factory.insert(:user)
    organization = ensure_user_organization(user)
    scope = Scope.for_user(user, organization: organization)

    opts =
      context
      |> Map.take([:token_authenticated_at])
      |> Enum.to_list()

    %{conn: log_in_user(conn, user, opts), user: user, organization: organization, scope: scope}
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_user(conn, user, opts \\ []) do
    token = TemplateApp.Accounts.generate_user_session_token(user)
    organization = ensure_user_organization(user)

    maybe_set_token_authenticated_at(token, opts[:token_authenticated_at])

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
    |> Plug.Conn.put_session(:active_organization_id, organization.id)
  end

  defp maybe_set_token_authenticated_at(_token, nil), do: nil

  defp maybe_set_token_authenticated_at(token, authenticated_at) do
    TemplateApp.TestHelpers.override_token_authenticated_at(token, authenticated_at)
  end

  defp ensure_user_organization(user) do
    case TemplateApp.Organizations.list_organizations_by_user(user) do
      [organization | _] ->
        organization

      [] ->
        organization = TemplateApp.Factory.insert(:organization)
        TemplateApp.Factory.insert(:membership, user: user, organization: organization)
        organization
    end
  end
end

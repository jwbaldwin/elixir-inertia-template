defmodule TemplateAppWeb.OrganizationInvitationController do
  @moduledoc """
  Controller for handling the invitation lifecycle (show and accept) 
  """
  use TemplateAppWeb, :controller

  alias TemplateApp.Organizations.Handlers.OrganizationInvite

  def show(conn, %{"token" => token}, scope) do
    {:ok, %{state: state, invitation: invitation}} =
      OrganizationInvite.show(scope, token)

    conn
    |> assign_prop(:token, token)
    |> assign_prop(:invitation, invitation)
    |> assign_prop(:state, to_string(state))
    |> assign_prop(:login_url, login_url(token))
    |> render_inertia("public/organization-invite")
  end

  def accept(conn, %{"token" => token}, scope) do
    case OrganizationInvite.accept(scope, token) do
      {:ok, invitation} ->
        conn
        |> put_session(:active_organization_id, invitation.organization_id)
        |> put_flash(:info, "Invitation accepted")
        |> redirect(to: ~p"/")

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Invitation link is invalid")
        |> redirect(to: ~p"/org/invites/#{token}")

      {:error, :expired} ->
        conn
        |> put_flash(:error, "Invitation has expired")
        |> redirect(to: ~p"/org/invites/#{token}")

      {:error, :email_mismatch} ->
        conn
        |> put_flash(:error, "This invitation was sent to a different email address")
        |> redirect(to: ~p"/org/invites/#{token}")

      {:error, :unconfirmed_user} ->
        conn
        |> put_flash(:error, "Confirm your account before accepting invitations")
        |> redirect(to: ~p"/org/invites/#{token}")

      {:error, :invalid_status} ->
        conn
        |> put_flash(:error, "This invitation is no longer pending")
        |> redirect(to: ~p"/org/invites/#{token}")

      {:error, :forbidden} ->
        conn
        |> put_flash(:error, "Log in to accept this invitation")
        |> redirect(to: ~p"/org/invites/#{token}")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "We could not accept this invitation")
        |> redirect(to: ~p"/org/invites/#{token}")
    end
  end

  defp login_url(token), do: "/login?return_to=#{URI.encode_www_form("/org/invites/#{token}")}"
end

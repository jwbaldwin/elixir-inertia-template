defmodule TemplateApp.Organizations.Finders.FindOrganizationInvitationByToken do
  @moduledoc """
  Finds an invitation by encoded token
  """

  import Ecto.Query, warn: false

  alias TemplateApp.Accounts.Invitation
  alias TemplateApp.Repo

  @hash_algorithm :sha256

  @doc @moduledoc
  @spec find(String.t()) :: {:ok, map()} | {:error, :not_found}
  def find(token) when is_binary(token) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        from(invitation in Invitation,
          where: invitation.token_hash == ^hashed_token,
          preload: [:organization, :inviter]
        )
        |> Repo.one()
        |> Repo.normalize_one()

      :error ->
        {:error, :not_found}
    end
  end

  def find(_), do: {:error, :not_found}
end

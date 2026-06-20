defmodule TemplateAppWeb.UserRegistrationController do
  use TemplateAppWeb, :controller

  alias TemplateApp.Accounts
  alias TemplateApp.Accounts.Organization

  def new(conn, _params) do
    conn
    |> assign_prop(:form, %{
      "name" => "",
      "email" => "",
      "company_name" => "",
      "password" => "",
      "password_confirmation" => ""
    })
    |> render_inertia("public/register")
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        conn
        |> put_flash(
          :info,
          "An email was sent to #{user.email}, please use the link to confirm your account."
        )
        |> redirect(to: ~p"/login")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> assign_errors(registration_errors(changeset))
        |> assign_prop(:form, registration_form(user_params))
        |> render_inertia("public/register")
    end
  end

  defp registration_errors(%Ecto.Changeset{data: %Organization{}, errors: errors} = changeset) do
    case Keyword.fetch(errors, :name) do
      {:ok, error} ->
        %{company_name: TemplateAppWeb.CoreComponents.translate_error(error)}

      :error ->
        case Keyword.fetch(errors, :slug) do
          {:ok, _error} ->
            %{
              company_name: "That company already exists. Ask an organization admin to invite you."
            }

          :error ->
            changeset
        end
    end
  end

  defp registration_errors(changeset), do: changeset

  defp registration_form(user_params) do
    %{
      "name" => registration_form_value(user_params, "name"),
      "email" => registration_form_value(user_params, "email"),
      "company_name" => registration_form_value(user_params, "company_name"),
      "password" => "",
      "password_confirmation" => ""
    }
  end

  defp registration_form_value(user_params, key) do
    case Map.get(user_params, key) do
      value when is_binary(value) -> value
      _ -> ""
    end
  end
end

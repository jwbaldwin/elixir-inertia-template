defmodule TemplateApp.Accounts.UserNotifier do
  @moduledoc false

  import Swoosh.Email

  alias TemplateApp.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"TemplateApp", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to confirm a newly registered account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to join an organization
  """
  def deliver_organization_invitation(email, url, organization_name, inviter_email, role) do
    deliver(email, "Organization invitation", """

    ==============================

    Hi #{email},

    #{inviter_email} invited you to join #{organization_name} as #{role}.

    You can review and accept this invitation by visiting the URL below:

    #{url}

    If you were not expecting this invitation, you can ignore this email.

    ==============================
    """)
  end
end

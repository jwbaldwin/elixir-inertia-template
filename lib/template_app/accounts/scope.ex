defmodule TemplateApp.Accounts.Scope do
  @moduledoc """
  Defines the scope of the caller to be used throughout the app

  The `TemplateApp.Accounts.Scope` allows public interfaces to receive
  information about the caller, such as if the call is initiated from an
  end-user, and if so, which user, and such a scope can carry fields
  such as "super user" or other privileges for use as authorization, or to
  ensure specific code paths can only be accessed for a given scope

  It is useful for logging as well as for scoping pubsub subscriptions and
  broadcasts when a caller subscribes to an interface or performs a particular
  action

  Feel free to extend the fields on this struct to fit the needs of
  growing application requirements
  """

  alias TemplateApp.Accounts.Organization
  alias TemplateApp.Accounts.User

  defstruct user: nil, organization: nil

  @type opts :: keyword() | map()

  @type t :: %__MODULE__{
          user: User.t() | nil,
          organization: %Organization{} | nil
        }

  @doc """
  Returns the current scope from a conn-like map
  """
  @spec current(%{assigns: map()}) :: t() | nil
  def current(%{assigns: %{current_scope: scope}}), do: scope
  def current(_), do: nil

  @doc """
  Creates a scope for the given user

  Returns nil if no user is given
  """
  @spec for_user(User.t() | nil) :: t() | nil
  @spec for_user(User.t() | nil, opts()) :: t() | nil
  def for_user(user, opts \\ [])

  def for_user(%User{} = user, opts) do
    opts =
      opts
      |> Map.new()
      |> Map.take([:organization])

    struct(__MODULE__, Map.put(opts, :user, user))
  end

  def for_user(nil, _opts), do: nil
end

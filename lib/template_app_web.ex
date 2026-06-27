defmodule TemplateAppWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use TemplateAppWeb, :controller
      use TemplateAppWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  use Boundary, deps: [TemplateApp], exports: [Endpoint, Telemetry]

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      import Phoenix.Controller
      import Phoenix.LiveView.Router

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, formats: [:html, :json]
      use Gettext, backend: TemplateAppWeb.Gettext

      import Inertia.Controller
      import Plug.Conn

      alias TemplateApp.Accounts.Scope

      unquote(verified_routes())

      def action(conn, _opts) do
        action = action_name(conn)

        if function_exported?(__MODULE__, action, 3) do
          apply(__MODULE__, action, [conn, conn.params, Scope.current(conn)])
        else
          apply(__MODULE__, action, [conn, conn.params])
        end
      end
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      import Inertia.HTML

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # Translation
      use Gettext, backend: TemplateAppWeb.Gettext

      import Phoenix.HTML
      import TemplateAppWeb.CoreComponents

      # HTML escaping functionality
      alias Phoenix.LiveView.JS
      # Core UI components
      alias TemplateAppWeb.Layouts

      # Common modules used in templates

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: TemplateAppWeb.Endpoint,
        router: TemplateAppWeb.Router,
        statics: TemplateAppWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end

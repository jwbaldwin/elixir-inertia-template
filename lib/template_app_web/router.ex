defmodule TemplateAppWeb.Router do
  use TemplateAppWeb, :router

  import TemplateAppWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {TemplateAppWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_scope_for_user)
    plug(Inertia.Plug)
  end

  pipeline :browser_json do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_scope_for_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", TemplateAppWeb do
    pipe_through(:api)

    get("/healthz", HealthController, :show)
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:template_app, :dev_routes) do
    import Oban.Web.Router
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: TemplateAppWeb.Telemetry)
      oban_dashboard("/oban")
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  ## Authentication routes
  scope "/", TemplateAppWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/register", UserRegistrationController, :new
    post "/register", UserRegistrationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end

  # Authed routes
  scope "/", TemplateAppWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/", HomeController, :index

    scope "/org" do
      put "/current", CurrentOrganizationController, :update

      resources "/settings", OrganizationSettingsController, only: [:show, :update], singleton: true

      resources "/settings/invitations", OrganizationInvitationsController,
        only: [:create, :delete],
        param: "invitation_id"

      post "/invites/:token/accept", OrganizationInvitationController, :accept

      resources "/settings/members", OrganizationMembersController,
        only: [:delete],
        param: "membership_id"
    end

    scope "/users" do
      resources "/settings", UserSettingsController, only: [:show, :update], singleton: true
      get "/settings/confirm-email/:token", UserSettingsController, :confirm_email
    end
  end

  # Unauthed routes
  scope "/", TemplateAppWeb do
    pipe_through [:browser]

    get "/org/invites/:token", OrganizationInvitationController, :show
    get "/login", UserSessionController, :new
    post "/login", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end

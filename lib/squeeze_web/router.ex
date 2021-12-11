defmodule SqueezeWeb.Router do
  use SqueezeWeb, :router

  alias SqueezeWeb.Plug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Squeeze.AuthPipeline
    plug Plug.Auth
    plug Plug.Locale
  end

  pipeline :live_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SqueezeWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Squeeze.AuthPipeline
    plug Plug.Locale
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :put_layout, {SqueezeWeb.LayoutView, :none}
    plug :put_resp_content_type, "application/json"
  end

  pipeline :api_auth do
    plug Squeeze.Api.AuthPipeline
    plug Plug.Auth
  end

  pipeline :dashboard_layout do
    plug Plug.RequireRegistered
    plug :put_layout, {SqueezeWeb.LayoutView, :dashboard}
  end

  pipeline :xml do
    plug :accepts, ["xml"]
    plug :put_layout, {SqueezeWeb.LayoutView, :none}
    plug :put_resp_content_type, "application/xml"
  end

  scope "/integration", SqueezeWeb do
    # Use the default browser stack
    pipe_through :browser

    get "/:provider", IntegrationController, :request
    get "/:provider/callback", IntegrationController, :callback
    post "/:provider/callback", IntegrationController, :callback
  end

  scope "/auth", SqueezeWeb do
    # Use the default browser stack
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
  end

  scope "/dashboard", SqueezeWeb do
    pipe_through [:live_browser]

    live "/calendar", CalendarLive, :index
    live "/challenges", ChallengeLive, :index
    live "/challenges/new", Challenges.NewLive, :new, as: :challenge
    live "/challenges/:id", Challenges.ShowLive, :show, as: :challenge
  end

  scope "/dashboard", SqueezeWeb do
    pipe_through [:browser, :dashboard_layout]

    get "/", DashboardController, :index

    # get "/challenges/:id", ChallengeController, :show

    get "/overview", OverviewController, :index

    get "/settings", ProfileController, :edit
    put "/settings", ProfileController, :update

    get "/billing", BillingController, :index
    put "/billing/cancel", BillingController, :cancel

    resources "/payment", PaymentMethodController, only: [:index, :new, :create, :delete]

    resources "/activities", ActivityController do
      patch "/mark-complete", ActivityController, :mark_complete, as: :mark_complete
    end

    resources "/plans", PlanController

    # resources "/challenges", ChallengeController, except: [:edit, :update, :delete]
    put "/challenges/:id/join", ChallengeController, :join
  end

  scope "/webhook", SqueezeWeb do
    get "/strava", StravaWebhookController, :challenge
    post "/strava", StravaWebhookController, :webhook

    get "/fitbit", FitbitWebhookController, :webhook
    post "/fitbit", FitbitWebhookController, :webhook

    post "/stripe", StripeWebhookController, :webhook

    get "/garmin", GarminWebhookController, :webhook
    post "/garmin", GarminWebhookController, :webhook
  end

  scope "/", SqueezeWeb do
    # Use the default browser stack
    pipe_through :browser

    get "/", HomeController, :index
    post "/", HomeController, :subscribe

    live "/evan", PageLive, :index

    get "/privacy", PageController, :privacy_policy
    get "/terms", PageController, :terms
    get "/support", PageController, :support

    get "/onboard", OnboardController, :index
    put "/onboard", OnboardController, :update

    get "/login", SessionController, :new
    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete

    get "/sign-up", UserController, :new
    post "/sign-up", UserController, :register
    put "/sign-up", UserController, :register

    get "/forgot-password", ForgotPasswordController, :show
    post "/forgot-password", ForgotPasswordController, :request

    get "/reset-password", ResetPasswordController, :show
    post "/reset-password", ResetPasswordController, :reset
    put "/reset-password", ResetPasswordController, :reset

    get "/invite/:slug", ChallengeShareController, :show
  end

  scope "/races", SqueezeWeb do
    pipe_through :browser

    get "/", SearchController, :index
    get "/:region", RegionSearchController, :index
    get "/:region/:slug", RaceController, :show
    post "/:region/:slug", RaceController, :subscribe
  end

  scope "/sitemap", SqueezeWeb do
    pipe_through :xml

    get "/index.xml", SitemapController, :index
  end

  scope "/api", SqueezeWeb.Api, as: :api do
    pipe_through :api

    post "/users/signup", UserController, :create
    post "/users/signin", UserController, :signin

    post "/google/auth", GoogleAuthController, :auth

    resources "/challenges", ChallengeController, only: [:show]
  end

  scope "/api", SqueezeWeb.Api, as: :api do
    pipe_through [:api, :api_auth]

    resources "/challenges", ChallengeController, only: [:index, :create]
    get "/challenges/:id/leaderboard", ChallengeController, :leaderboard
    get "/challenges/:id/status", ChallengeController, :status
    put "/challenges/:id/join", ChallengeController, :join

    get "/challenges/:id/activities", ChallengeActivityController, :index

    post "/strava/exchange", StravaController, :exchange_code

    resources "/push_tokens", PushTokenController, only: [:create]

    get "/segments/starred", SegmentController, :starred
    get "/segments/:id", SegmentController, :show

    put "/users/me", UserController, :update
    get "/users/me", UserController, :me
    get "/users/:slug", UserController, :show

    put "/user_prefs/me", UserPrefsController, :update

    get "/users/me/activities", ActivityController, :index

    get "/users/:slug/follows", FollowController, :index
    post "/follow/:slug", FollowController, :follow
    delete "/unfollow/:slug", FollowController, :unfollow
  end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end
end

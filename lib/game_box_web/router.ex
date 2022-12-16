defmodule GameBoxWeb.Router do
  use GameBoxWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {GameBoxWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug GameBoxWeb.SessionPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GameBoxWeb do
    pipe_through :browser

    live_session(:default, on_mount: GameBoxWeb.InitAssigns) do
      live "/", HomeLive
      live "/arena/:arena_id", ArenaLive
      live "/arena/:arena_id/game/:game_id", GameLive
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", GameBoxWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GameBoxWeb.Telemetry
    end
  end
end

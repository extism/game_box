defmodule GameBoxWeb.RequireAuth do
  @moduledoc """
  Plug that ensures that a user is logged in
  """
  import Plug.Conn
  alias GameBoxWeb.Router.Helpers, as: Routes
  alias GameBox.User
  alias Phoenix.Controller

  def init(opts), do: opts

  def call(%Plug.Conn{assigns: %{current_user: %User{is_banned: false}}} = conn, _opts), do: conn

  def call(conn, _) do
    conn
    |> Controller.put_flash(:info, "You must be logged in to view this page.")
    |> Controller.redirect(to: Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.WelcomeLive))
    |> halt()
  end
end

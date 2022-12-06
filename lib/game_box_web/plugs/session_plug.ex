defmodule GameBoxWeb.SessionPlug do
  import Plug.Conn
  import Phoenix.Controller

  alias GameBoxWeb.Router.Helpers, as: Routes

  def init(opts) do
    opts
  end

  def call(%{params: %{"username" => "" <> username}} = conn, _opts) do
    conn
    |> put_session(:username, username)
    |> redirect(to: Routes.live_path(conn, GameBoxWeb.HomeLive))
    |> halt()
  end

  def call(conn, _opts) do
    conn
  end
end

defmodule GameBoxWeb.RequireAuthTest do
  @moduledoc false
  use GameBoxWeb.ConnCase
  import GameBox.Factory
  alias GameBoxWeb.RequireAuth

  describe "call/2" do
    test "returns the conn without redirecting when it has a current user", %{conn: conn} do
      user = insert(:user)
      conn = assign(conn, :current_user, user)

      assert RequireAuth.call(conn, []) == conn
    end

    test "redirects to welcome live without authentication", %{conn: conn} do
      assert conn
             |> Phoenix.Controller.fetch_flash()
             |> RequireAuth.call([])
             |> redirected_to() =~ Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.HomeLive)
    end

    test "redirects to welcome live when user is banned", %{conn: conn} do
      user = insert(:user, is_banned: true)
      conn = assign(conn, :current_user, user)

      assert conn
             |> Phoenix.Controller.fetch_flash()
             |> RequireAuth.call([])
             |> redirected_to() =~ Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.HomeLive)
    end
  end
end

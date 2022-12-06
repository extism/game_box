defmodule GameBoxWeb.HomeLiveTest do
  use GameBoxWeb.ConnCase

  describe "home" do
    test "renders with username", ctx do
      %{conn: conn} = ctx
      username = get_session(conn, :username)
      {:ok, _view, html} = live(conn, Routes.live_path(conn, GameBoxWeb.HomeLive))
      assert html =~ "Current User: #{username}"
    end

    test "renders without username", _ctx do
      conn = build_conn()
      {:ok, _view, html} = live(conn, Routes.live_path(conn, GameBoxWeb.HomeLive))
      refute html =~ "Current User: "
    end

    test "can set username" do
      conn = build_conn()
      conn = get(conn, Routes.live_path(conn, GameBoxWeb.HomeLive), %{username: "Test"})
      assert redirected_to(conn) == Routes.live_path(conn, GameBoxWeb.HomeLive)
      assert get_session(conn, :username) == "Test"
    end
  end
end

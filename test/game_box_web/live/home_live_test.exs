defmodule GameBoxWeb.HomeLiveTest do
  use GameBoxWeb.ConnCase

  describe "home" do
    test "sets a user id in session", ctx do
      %{conn: conn} = ctx
      conn = get(conn, Routes.live_path(conn, GameBoxWeb.HomeLive))
      assert "" <> _ = get_session(conn, :user_id)
    end

    test "renders with forms", ctx do
      %{conn: conn} = ctx
      {:ok, _view, html} = live(conn, Routes.live_path(conn, GameBoxWeb.HomeLive))
      assert html =~ "Create a Game"
      assert html =~ "Join a Game"
    end

    test "create a game", ctx do
      %{conn: conn} = ctx
      {:ok, view, _html} = live(conn, Routes.live_path(conn, GameBoxWeb.HomeLive))

      view
      |> element("#create_game")
      |> render_submit(%{player_id: "Test"})

      path = Routes.live_path(conn, GameBoxWeb.ArenaLive, %{player_id: "Test"})
      {^path, %{}} = assert_redirect(view)
    end

    test "join a game", ctx do
      %{conn: conn} = ctx
      {:ok, view, _html} = live(conn, Routes.live_path(conn, GameBoxWeb.HomeLive))

      code = GameBox.Arena.start_arena()

      view
      |> element("#join_game")
      |> render_submit(%{player_id: "Test", code: code})

      assert_redirected(view, Routes.live_path(conn, GameBoxWeb.ArenaLive, %{code: code}))
    end
  end
end

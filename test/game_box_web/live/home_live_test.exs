defmodule GameBoxWeb.HomeLiveTest do
  use GameBoxWeb.ConnCase

  describe "home" do
    test "join an arena", ctx do
      %{conn: conn} = ctx
      {:ok, view, _html} = live(conn, ~p"/")

      player = GameBox.Arena.Player.new("one")

      view
      |> element("#join_arena")
      |> render_submit(%{player_id: player.id, arena_code: "ABC"})

      path = ~p"/arena?code=ABC&player_id=#{player.id}"
      {^path, %{}} = assert_redirect(view)
    end

    test "arena with two players", ctx do
      %{conn: conn} = ctx

      arena_code = "CDE"
      player_one = GameBox.Arena.Player.new("one")
      player_two = GameBox.Arena.Player.new("two")
      {:ok, :started} = GameBox.Arena.Server.start_or_join(arena_code, player_one)
      {:ok, :joined} = GameBox.Arena.Server.start_or_join(arena_code, player_two)

      {:ok, view, _html} = live(conn, ~p"/arena?code=#{arena_code}&player_id=#{player_one.id}")

      html = render(view)
      assert html =~ "Current Player: one"
      assert html =~ "two"
    end
  end
end

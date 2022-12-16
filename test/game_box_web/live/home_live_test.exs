defmodule GameBoxWeb.HomeLiveTest do
  use GameBoxWeb.ConnCase

  describe "home" do
    test "join an arena", ctx do
      %{conn: conn} = ctx
      {:ok, view, _html} = live(conn, ~p"/")
      player_id = get_session(conn, :player_id)

      view
      |> element("#join_arena")
      |> render_submit(%{player_name: "Joe", arena_id: "ABC"})

      path = ~p"/arena/ABC"
      assert {^path, %{}} = assert_redirect(view)
      assert %{id: ^player_id, name: "Joe"} = GameBox.Players.get_player("ABC", player_id)
      assert %{arena_id: "ABC"} = GameBox.Arena.state("ABC")
    end
  end
end

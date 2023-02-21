defmodule GameBoxWeb.HomeLiveTest do
  use GameBoxWeb.ConnCase

  describe "home" do
    test "join an arena", ctx do
      %{conn: conn} = ctx
      {:ok, view, _html} = live(conn, Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.HomeLive))
      player_id = get_session(conn, :player_id)

      view
      |> element("#join_arena")
      |> render_submit(%{arena_form: %{player_name: "Joe", arena_id: "ABCD"}})

      path = ~p"/arena/ABCD"
      assert {^path, %{}} = assert_redirect(view)
      assert %{id: ^player_id, name: "Joe"} = GameBox.Players.get_player("ABCD", player_id)
      assert %{arena_id: "ABCD"} = GameBox.Arena.state("ABCD")
    end
  end
end

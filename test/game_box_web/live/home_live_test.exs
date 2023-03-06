defmodule GameBoxWeb.HomeLiveTest do
  use GameBoxWeb.ConnCase
  alias GameBox.Arena

  describe "home" do
    test "join an arena", ctx do
      %{conn: conn} = ctx
      {:ok, view, _html} = live(conn, Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.HomeLive))
      player_id = get_session(conn, :player_id)
      arena_id = "abcd"
      Arena.start(arena_id)

      view
      |> element("#join_arena")
      |> render_submit(%{arena_form: %{player_name: "Joe", arena_id: arena_id}})

      path = ~p"/arena/abcd"
      assert {^path, %{}} = assert_redirect(view)
      assert %{id: ^player_id, name: "JOE"} = GameBox.Players.get_player(arena_id, player_id)
      assert %{arena_id: ^arena_id} = GameBox.Arena.state(arena_id)
    end
  end
end

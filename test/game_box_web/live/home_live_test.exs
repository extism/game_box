defmodule GameBoxWeb.HomeLiveTest do
  use GameBoxWeb.ConnCase
  alias GameBox.Arena

  alias GameBox.Arena

  describe "home" do
    test "join an arena when it does not exist", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.HomeLive))

      assert view
             |> element("#join_arena")
             |> render_submit(%{arena_form: %{player_name: "Matt", arena_id: "AAAA"}}) =~
               "Oops! That arena does not exist."
    end

    test "join an arena when it does exist", %{conn: conn} do
      assert {:ok, :initiated} = Arena.start("BBBB")
      assert %{arena_id: "bbbb"} = GameBox.Arena.state("BBBB")

      {:ok, view, _html} = live(conn, Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.HomeLive))

      player_id = get_session(conn, :player_id)
      arena_id = "abcd"
      Arena.start(arena_id)

      view
      |> element("#join_arena")
      |> render_submit(%{arena_form: %{player_name: "Joe", arena_id: "Bbbb"}})

      path = ~p"/arena/bbbb"
      assert assert_redirect(view, path)
      assert %{id: ^player_id, name: "JOE"} = GameBox.Players.get_player("BBBB", player_id)
    end
  end
end

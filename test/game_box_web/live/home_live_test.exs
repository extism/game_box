defmodule GameBoxWeb.HomeLiveTest do
  use GameBoxWeb.ConnCase
  alias GameBox.Arena

  @arena_id "AAAA"

  setup do
    on_exit(fn ->
      # We sleep at the end of each test to allow the genservers to get torn down. This value correlates to
      # the 'tear_down_timeout' set in test.exs
      :timer.sleep(50)
    end)
  end

  describe "home" do
    test "join an arena when it does not exist", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.HomeLive))

      assert view
             |> element("#join_arena")
             |> render_submit(%{arena_form: %{player_name: "Matt", arena_id: "ABCD"}}) =~
               "Oops! That arena does not exist."
    end

    test "join an arena when it does exist", %{conn: conn} do
      assert {:ok, :initiated} = Arena.start(@arena_id)
      assert %{arena_id: "aaaa"} = GameBox.Arena.state(@arena_id)

      {:ok, view, _html} = live(conn, Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.HomeLive))

      player_id = get_session(conn, :player_id)

      view
      |> element("#join_arena")
      |> render_submit(%{arena_form: %{player_name: "Joe", arena_id: @arena_id}})

      path = ~p"/arena/aaaa"
      assert assert_redirect(view, path)
      assert %{id: ^player_id, name: "JOE"} = GameBox.Players.get_player(@arena_id, player_id)

      live(conn, ~p"/")
    end
  end
end

defmodule GameBoxWeb.ArenaLiveTest do
  use GameBoxWeb.ConnCase

  alias GameBox.Arena
  alias GameBox.Players

  describe "arena" do
    test "shows arena with two players", ctx do
      %{conn: conn} = ctx

      conn2 =
        Phoenix.ConnTest.build_conn()
        |> Phoenix.ConnTest.init_test_session(%{player_id: Ecto.UUID.generate()})

      arena_id = "CDE"
      player_one_id = get_session(conn, :player_id)
      player_two_id = get_session(conn2, :player_id)

      :ok = Players.start(arena_id)
      :ok = Arena.start(arena_id)

      Players.update_player(arena_id, player_one_id, %{name: "Test 1"})
      Players.update_player(arena_id, player_two_id, %{name: "Test 2"})

      {:ok, view1, _html} = live(conn, ~p"/arena/#{arena_id}")
      live(conn2, ~p"/arena/#{arena_id}")

      html = render(view1)

      assert html =~ "Test 1"
      assert html =~ "Test 2"
    end
  end
end

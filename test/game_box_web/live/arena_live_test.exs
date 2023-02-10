defmodule GameBoxWeb.ArenaLiveTest do
  @moduledoc false
  use GameBoxWeb.ConnCase

  alias GameBox.Arena
  alias GameBox.Players

  setup ctx do
    path = "tictactoe.wasm"
    disk_volume_path = Application.get_env(:game_box, :disk_volume_path)
    dest = Path.join([disk_volume_path, Path.basename(path)])
    File.mkdir_p(disk_volume_path)
    File.cp!(path, dest)

    on_exit(fn ->
      File.rm_rf("test/uploads")
    end)

    %{conn: conn} = ctx
    game = insert(:game)

    conn2 =
      Phoenix.ConnTest.build_conn()
      |> Phoenix.ConnTest.init_test_session(%{player_id: Ecto.UUID.generate()})

    arena_id = "ABCD"
    player_one_id = get_session(conn, :player_id)
    player_two_id = get_session(conn2, :player_id)

    Arena.start(arena_id)
    Arena.set_host(arena_id, player_one_id)

    :ok = Players.start(arena_id)

    Players.update_player(arena_id, player_one_id, %{name: "Test 1"})
    Players.update_player(arena_id, player_two_id, %{name: "Test 2"})

    {:ok,
     arena_id: arena_id,
     conn: conn,
     conn2: conn2,
     game: game,
     player_one_id: player_one_id,
     player_two_id: player_two_id}
  end

  describe "arena" do
    test "first person to join becomes arena host", %{
      arena_id: arena_id,
      conn: conn,
      conn2: conn2
    } do
      {:ok, _view1, html1} = live(conn, ~p"/arena/#{arena_id}")
      {:ok, _view2, html2} = live(conn2, ~p"/arena/#{arena_id}")

      assert html1 =~ "Test 1"
      assert html1 =~ "Choose a game to start playing"

      assert html2 =~ "Test 2"
    end

    test "host can select a game", %{
      arena_id: arena_id,
      conn: conn,
      conn2: conn2,
      game: game
    } do
      {:ok, view1, html1} = live(conn, ~p"/arena/#{arena_id}")
      {:ok, view2, html2} = live(conn2, ~p"/arena/#{arena_id}")

      assert html1 =~ game.title
      assert html1 =~ "Choose a game to start playing"
      refute html2 =~ game.title
      refute html2 =~ "Choose a game to start playing"

      render_click(view1, :select_game, %{"game_id" => game.id})

      html1 = render(view1)
      html2 = render(view2)

      assert html1 =~ game.description
      assert html2 =~ game.description

      assert html1 =~ "Start Game"
      refute html2 =~ "Start Game"
    end

    test "host can start game", %{
      arena_id: arena_id,
      conn: conn,
      conn2: conn2,
      game: game
    } do
      {:ok, view1, html1} = live(conn, ~p"/arena/#{arena_id}")
      {:ok, _view2, _html2} = live(conn2, ~p"/arena/#{arena_id}")

      assert html1 =~ game.title
      assert html1 =~ "Choose a game to start playing"

      render_click(view1, :select_game, %{"game_id" => game.id})
      render_click(view1, :start_game, %{"game_id" => game.id})

      refute render(view1) =~ "Start Game"
    end
  end
end

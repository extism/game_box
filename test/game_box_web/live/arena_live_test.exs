defmodule GameBoxWeb.ArenaLiveTest do
  @moduledoc false
  use GameBoxWeb.ConnCase

  alias GameBox.Arena
  alias GameBox.Players

  setup do
    path = "tictactoe.wasm"
    disk_volume_path = Application.get_env(:game_box, :disk_volume_path)
    dest = Path.join([disk_volume_path, Path.basename(path)])
    File.mkdir_p(disk_volume_path)
    File.cp!(path, dest)

    on_exit(fn ->
      File.rm_rf("test/uploads")
    end)
  end

  describe "arena" do
    test "host can start and select a game", %{conn: conn} do
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

      {:ok, _view1, html1} = live(conn, ~p"/arena/#{arena_id}")
      {:ok, _view2, html2} = live(conn2, ~p"/arena/#{arena_id}")

      assert html1 =~ "Test 1"
      assert html1 =~ "Choose a game to start playing"

      assert html2 =~ "Test 2"
    end

    test "host can select and unselect a game", %{
      conn: conn
    } do
      game = insert(:game)

      conn2 =
        Phoenix.ConnTest.build_conn()
        |> Phoenix.ConnTest.init_test_session(%{player_id: Ecto.UUID.generate()})

      arena_id = "AAAA"
      player_one_id = get_session(conn, :player_id)
      player_two_id = get_session(conn2, :player_id)

      Arena.start(arena_id)
      Arena.set_host(arena_id, player_one_id)

      :ok = Players.start(arena_id)

      Players.update_player(arena_id, player_one_id, %{name: "Test 1"})
      Players.update_player(arena_id, player_two_id, %{name: "Test 2"})

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
      assert html1 =~ "Unselect Game"
      refute html2 =~ "Start Game"
      refute html2 =~ "Unselect Game"

      render_click(view1, :unselect_game, %{"game_id" => game.id})

      html1 = render(view1)
      html2 = render(view2)

      assert html1 =~ game.title
      assert html1 =~ "Choose a game to start playing"
      refute html2 =~ game.title
      refute html2 =~ "Choose a game to start playing"
    end

    test "host can start game", %{
      conn: conn
    } do
      game = insert(:game)

      conn2 =
        Phoenix.ConnTest.build_conn()
        |> Phoenix.ConnTest.init_test_session(%{player_id: Ecto.UUID.generate()})

      arena_id = "BBBB"
      player_one_id = get_session(conn, :player_id)
      player_two_id = get_session(conn2, :player_id)

      Arena.start(arena_id)
      Arena.set_host(arena_id, player_one_id)

      :ok = Players.start(arena_id)

      Players.update_player(arena_id, player_one_id, %{name: "Test 1"})
      Players.update_player(arena_id, player_two_id, %{name: "Test 2"})

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

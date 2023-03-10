defmodule GameBoxWeb.ArenaLiveTest do
  @moduledoc false
  use GameBoxWeb.ConnCase

  alias GameBox.Arena
  alias GameBox.Players

  @arena_id "AAAA"

  setup do
    path = "tictactoe.wasm"
    disk_volume_path = Application.get_env(:game_box, :disk_volume_path)
    dest = Path.join([disk_volume_path, Path.basename(path)])
    File.mkdir_p(disk_volume_path)
    File.cp!(path, dest)

    on_exit(fn ->
      File.rm_rf("test/uploads")

      # We sleep at the end of each test to allow the genservers to get torn down. This value correlates to
      # the 'tear_down_timeout' set in test.exs
      :timer.sleep(50)
    end)
  end

  describe "arena" do
    test "host has option to select a game", %{conn: conn} do
      conn2 =
        Phoenix.ConnTest.build_conn()
        |> Phoenix.ConnTest.init_test_session(%{player_id: Ecto.UUID.generate()})

      player_one_id = get_session(conn, :player_id)
      player_two_id = get_session(conn2, :player_id)

      Arena.start(@arena_id)
      Arena.set_host(@arena_id, player_one_id)

      {:ok, _} = Players.start(@arena_id)

      Players.update_player(@arena_id, player_one_id, %{
        name: "Test 1",
        joined_at: DateTime.utc_now() |> DateTime.to_unix()
      })

      Players.update_player(@arena_id, player_two_id, %{
        name: "Test 2",
        joined_at: DateTime.utc_now() |> DateTime.to_unix()
      })

      {:ok, _view1, html1} = live(conn, ~p"/arena/#{@arena_id}")
      {:ok, _view2, html2} = live(conn2, ~p"/arena/#{@arena_id}")

      assert html1 =~ "select a game from below to get started!"
      assert html2 =~ "Waiting for "

      simulate_arena_teardown([conn, conn2])
    end

    test "host can select and unselect a game", %{
      conn: conn
    } do
      game = insert(:game)

      conn2 =
        Phoenix.ConnTest.build_conn()
        |> Phoenix.ConnTest.init_test_session(%{player_id: Ecto.UUID.generate()})

      player_one_id = get_session(conn, :player_id)
      player_two_id = get_session(conn2, :player_id)

      Arena.start(@arena_id)
      Arena.set_host(@arena_id, player_one_id)

      {:ok, _} = Players.start(@arena_id)

      Players.update_player(@arena_id, player_one_id, %{
        name: "Test 1",
        joined_at: DateTime.utc_now() |> DateTime.to_unix()
      })

      Players.update_player(@arena_id, player_two_id, %{
        name: "Test 2",
        joined_at: DateTime.utc_now() |> DateTime.to_unix()
      })

      {:ok, view1, html1} = live(conn, ~p"/arena/#{@arena_id}")
      {:ok, view2, html2} = live(conn2, ~p"/arena/#{@arena_id}")

      assert html1 =~ game.title
      # assert html1 =~ "select a game from below to get started!"

      assert html2 =~ "Waiting for"
      refute html2 =~ game.title

      render_click(view1, :select_game, %{"game-id" => game.id})

      html1 = render(view1)
      html2 = render(view2)

      assert html1 =~ game.description
      assert html2 =~ game.description

      assert html1 =~ "Start Game"
      assert html1 =~ "unselect_game"
      refute html2 =~ "Start Game"
      refute html2 =~ "unselect_game"

      render_click(view1, :unselect_game, %{"game-id" => game.id})

      html1 = render(view1)
      html2 = render(view2)

      assert html1 =~ game.title
      assert html1 =~ "select a game from below to get started!"
      refute html2 =~ game.title
      refute html2 =~ "select a game from below to get started!"

      simulate_arena_teardown([conn, conn2])
    end

    test "host can start game", %{
      conn: conn
    } do
      game = insert(:game)

      conn2 =
        Phoenix.ConnTest.build_conn()
        |> Phoenix.ConnTest.init_test_session(%{player_id: Ecto.UUID.generate()})

      player_one_id = get_session(conn, :player_id)
      player_two_id = get_session(conn2, :player_id)

      Arena.start(@arena_id)
      Arena.set_host(@arena_id, player_one_id)

      {:ok, _} = Players.start(@arena_id)

      Players.update_player(@arena_id, player_one_id, %{
        name: "Test 1",
        joined_at: DateTime.utc_now() |> DateTime.to_unix()
      })

      Players.update_player(@arena_id, player_two_id, %{
        name: "Test 2",
        joined_at: DateTime.utc_now() |> DateTime.to_unix()
      })

      {:ok, view1, html1} = live(conn, ~p"/arena/#{@arena_id}")
      {:ok, _view2, _html2} = live(conn2, ~p"/arena/#{@arena_id}")

      assert html1 =~ game.title
      assert html1 =~ "select a game from below to get started!"

      render_click(view1, :select_game, %{"game-id" => game.id})
      render_click(view1, :start_game, %{"game-id" => game.id})

      refute render(view1) =~ "Start Game"

      simulate_arena_teardown([conn, conn2])
    end
  end

  # We navigate back to the home page (any page that isn't the arena would do)
  # so that the genservers get torn down.
  defp simulate_arena_teardown(conns) do
    Enum.each(conns, &live(&1, ~p"/"))
  end
end

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

    # test "upload a game and play", ctx do
    #   %{conn: player_one_conn} = ctx
    #   arena_id = "DEF"
    #   {:ok, view, _html} = live(player_one_conn, ~p"/")

    #   path = "games/tictactoe/target/wasm32-unknown-unknown/release/tictactoe_rs.wasm"
    #   content = File.read!(path)
    #   stat = File.stat!(path)
    #   game = file_input(view, "#upload_game", :game, [
    #     %{
    #       last_modified: stat.mtime,
    #       name: "tictactoe_rs.wasm",
    #       content: content,
    #       size: stat.size,
    #       type: "application/wasm"
    #     }
    #   ])
    #   render_upload(game, "tictactoe_rs.wasm")

    #   view
    #   |> element("#upload_game")
    #   |> render_submit(%{title: "Tic Tac Toe"})

    #   view
    #   |> element("#join_arena")
    #   |> render_submit(%{player_name: "Joe", arena_id: "#{arena_id}"})

    #   player_two_conn =
    #     Phoenix.ConnTest.init_test_session(Phoenix.ConnTest.build_conn(), %{player_id: Ecto.UUID.generate()})
    #   player_two_id = get_session(player_two_conn, :player_id)
    #   GameBox.Players.update_player(arena_id, player_two_id, %{name: "Bob"})

    #   {:ok, player_one_view, _html} = live(player_one_conn, ~p"/arena/#{arena_id}")
    #   {:ok, player_two_view, _html} = live(player_two_conn, ~p"/arena/#{arena_id}")

    #   player_one_view
    #   |> element("#games > li > button")
    #   |> render_click()

    #   player_one_view
    #   |> element("button[phx-value-cell=0]")
    #   |> render_click(%{value: ""})

    #   assert has_element?(player_two_view, "button[phx-value-cell=0]", "X")
    #   assert has_element?(player_one_view, "button[phx-value-cell=0]", "X")

    #   player_two_view
    #   |> element("button[phx-value-cell=1]")
    #   |> render_click(%{value: ""})

    #   assert has_element?(player_two_view, "button[phx-value-cell=1]", "O")
    #   assert has_element?(player_one_view, "button[phx-value-cell=1]", "O")

    #   player_one_view
    #   |> element("button[phx-value-cell=2]")
    #   |> render_click(%{value: ""})

    #   assert has_element?(player_two_view, "button[phx-value-cell=2]", "X")
    #   assert has_element?(player_one_view, "button[phx-value-cell=2]", "X")

    #   player_two_view
    #   |> element("button[phx-value-cell=3]")
    #   |> render_click(%{value: ""})

    #   assert has_element?(player_two_view, "button[phx-value-cell=3]", "O")
    #   assert has_element?(player_one_view, "button[phx-value-cell=3]", "O")

    #   player_one_view
    #   |> element("button[phx-value-cell=4]")
    #   |> render_click(%{value: ""})

    #   assert has_element?(player_two_view, "button[phx-value-cell=4]", "X")
    #   assert has_element?(player_one_view, "button[phx-value-cell=4]", "X")

    #   player_two_view
    #   |> element("button[phx-value-cell=5]")
    #   |> render_click(%{value: ""})

    #   assert has_element?(player_two_view, "button[phx-value-cell=5]", "O")
    #   assert has_element?(player_one_view, "button[phx-value-cell=5]", "O")

    #   player_one_view
    #   |> element("button[phx-value-cell=6]")
    #   |> render_click(%{value: ""})

    #   assert has_element?(player_two_view, "button[phx-value-cell=6]", "X")
    #   assert has_element?(player_one_view, "button[phx-value-cell=6]", "X")

    #   player_two_view
    #   |> element("button[phx-value-cell=7]")
    #   |> render_click(%{value: ""})

    #   assert has_element?(player_two_view, "button[phx-value-cell=7]", "O")
    #   assert has_element?(player_one_view, "button[phx-value-cell=7]", "O")

    #   player_one_view
    #   |> element("button[phx-value-cell=8]")
    #   |> render_click(%{value: ""})

    #   assert has_element?(player_two_view, "button[phx-value-cell=8]", "X")
    #   assert has_element?(player_one_view, "button[phx-value-cell=8]", "X")

    #   assert has_element?(player_one_view, "button[phx-value-cell=0].winner-true")
    #   assert has_element?(player_one_view, "button[phx-value-cell=4].winner-true")
    #   assert has_element?(player_one_view, "button[phx-value-cell=8].winner-true")
    #   assert has_element?(player_two_view, "button[phx-value-cell=0].winner-true")
    #   assert has_element?(player_two_view, "button[phx-value-cell=4].winner-true")
    #   assert has_element?(player_two_view, "button[phx-value-cell=8].winner-true")
    # end
  end
end

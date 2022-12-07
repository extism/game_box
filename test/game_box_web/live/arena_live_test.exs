defmodule GameBoxWeb.ArenaLiveTest do
  use GameBoxWeb.ConnCase

  describe "arena" do
    setup do
      code = GameBox.Arena.start_arena()
      player_id = "Test"
      %{code: code, player_id: player_id}
    end

    test "renders the board", ctx do
      %{conn: conn, code: code, player_id: player_id} = ctx
      {:ok, view, _html} = live(conn, Routes.live_path(conn, GameBoxWeb.ArenaLive, %{code: code, player_id: player_id}))
      assert has_element?(view, ".board")
    end
  end
end

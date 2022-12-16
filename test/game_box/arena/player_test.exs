defmodule GameBox.Arena.PlayerTest do
  use GameBox.DataCase

  alias GameBox.Players

  describe "players" do
    setup do
      %{arena_id: Ecto.UUID.generate(), player_id: Ecto.UUID.generate()}
    end

    test "successfully starts", ctx do
      %{arena_id: arena_id} = ctx
      assert :ok = Players.start(arena_id)
    end

    test "can update and list players information", ctx do
      %{arena_id: arena_id, player_id: player_id} = ctx
      assert :ok = Players.start(arena_id)

      assert {:ok,
              %{
                id: ^player_id,
                name: "Test"
              }} = Players.update_player(arena_id, player_id, %{name: "Test"})

      Players.monitor(arena_id, player_id)
      pid = self()
      assert %{pids: [^pid]} = Players.get_player(arena_id, player_id)
    end
  end
end

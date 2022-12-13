defmodule GameBox.Arena.PlayerTest do
  use GameBox.DataCase

  alias GameBox.Players

  describe "players" do
    test "successfully starts" do
      assert :ok = Players.start("A")
    end

    test "can update and list players information" do
      player_id = Ecto.UUID.generate()
      assert :ok = Players.start("B")

      assert {:ok,
              %{
                id: ^player_id,
                name: "Test"
              }} = Players.update_player("B", player_id, %{name: "Test"})

      assert %{^player_id => %{id: ^player_id}} = Players.list_players("B")
    end
  end
end

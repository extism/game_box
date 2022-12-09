defmodule GameBox.Arena.State do

  alias GameBox.Arena.State

  defstruct [
    code: nil,
    players: []
  ]

  @type code :: String.t()

  def new(code, player) do
    %__MODULE__{
      code: code,
      players: [player]
    }
  end

  def join_player(%State{players: players} = state, player) do
    players =
      if Enum.any?(players, fn %{id: id} -> id == player.id end) do
        players
      else
        [player] ++ players
      end

    Map.put(state, :players, players)
  end

  def get_player(%State{players: players}, player_id) do
    Enum.find(players, & &1.id == player_id)
  end
end

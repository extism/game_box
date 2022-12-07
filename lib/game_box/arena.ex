defmodule GameBox.Arena do

  def start_arena do
    code = generate_code()
    {:ok, _pid} = GameBox.Arena.Server.start_link(code)
    {:ok, _plugin} = load_game(code, "/Users/ben/d/game_box/games/tictactoe/target/wasm32-unknown-unknown/debug/tictactoe_rs.wasm")
    {:ok, _plugin} = init_game(code, ["benjamin", "brian"])
    code
  end

  def load_game(code, path) do
    GameBox.Arena.Server.load(code, %{ wasm: [ %{ path: path } ]}, false)
  end

  def init_game(code, player_ids) do
    GameBox.Arena.Server.exec(code, {:call, "init_game", JSON.encode!(%{player_ids: player_ids})})
  end

  def fetch(code) do
    GameBox.Arena.Registry.whereis_name(code)
  end

  def generate_code do
    code = for _ <- 1..4, into: "", do: <<Enum.random('ABCDEFGHIJKLMNOPQRSTUVWXYZ')>>

    if GameBox.Arena.Server.exists?(code) do
      generate_code()
    else
      code
    end
  end
end

defmodule GameBox.Arena do

  def start_arena(code) do
    # TODO change this out
    GameBox.Arena.Server.start_link(code)
    #load_game(code, path)
  end

  def load_game(code, path) do
    GameBox.Arena.Server.load(code, %{ wasm: [ %{ path: path } ]}, false)
  end

  def fetch(code) do
    GameBox.Arena.Registry.whereis_name(code)
  end
end

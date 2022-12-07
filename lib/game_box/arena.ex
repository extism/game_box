defmodule GameBox.Arena do

  def start_arena do
    code = generate_code()
    GameBox.Arena.Server.start_link(code)
    code
  end

  def load_game(code, path) do
    GameBox.Arena.Server.load(code, %{ wasm: [ %{ path: path } ]}, false)
  end

  def fetch(code) do
    GameBox.Arena.Registry.whereis_name(code)
  end

  def generate_code do
    code = for _ <- 1..5, into: "", do: <<Enum.random('ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890')>>

    if GameBox.Arena.Server.exists?(code) do
      generate_code()
    else
      code
    end
  end
end

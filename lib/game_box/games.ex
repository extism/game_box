defmodule GameBox.Games do
  @moduledoc false

  alias GameBox.Games.Game
  alias GameBox.Repo

  def create_game(attrs) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  def list_games do
    Repo.all(Game)
  end
end

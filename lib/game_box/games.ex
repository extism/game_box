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

  def get_game(game_id) do
    game = Repo.get(Game, game_id)

    if is_nil(game) do
      {:error, :not_found}
    else
      {:ok, game}
    end
  end
end

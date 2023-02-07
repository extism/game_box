defmodule GameBox.Games do
  @moduledoc false

  alias GameBox.Games.Game
  alias GameBox.Repo

  import Ecto.Query

  @spec create_game(map()) :: {:ok, Game.t()} | {:error, Ecto.Changeset.t()}
  def create_game(attrs) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  @spec list_games :: list(Game.t()) | []
  def list_games do
    Repo.all(Game)
  end

  @spec list_games_for_user(integer()) :: list(Game.t()) | []
  def list_games_for_user(user_id) do
    Game
    |> where([g], g.user_id == ^user_id)
    |> Repo.all()
  end

  @spec get_game(integer()) :: {:error, :not_found} | {:ok, Game.t()}
  def get_game(game_id) do
    game = Repo.get(Game, game_id)

    if is_nil(game) do
      {:error, :not_found}
    else
      {:ok, game}
    end
  end
end

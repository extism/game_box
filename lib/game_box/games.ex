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
    Game
    |> join(:inner, [g], u in assoc(g, :user), as: :user)
    |> where([user: user], user.is_banned == false)
    |> preload([:user])
    |> Repo.all()
  end

  @spec list_games_for_user(integer()) :: list(Game.t()) | []
  def list_games_for_user(user_id) do
    Game
    |> where([g], g.user_id == ^user_id)
    |> Repo.all()
  end

  def get_game(game_id) when is_bitstring(game_id) do
    game_id
    |> String.to_integer()
    |> get_game()
  end

  @spec get_game(integer()) :: {:error, :not_found} | {:ok, Game.t()}
  def get_game(game_id) when is_integer(game_id) do
    Game
    |> join(:inner, [g], u in assoc(g, :user), as: :user)
    |> where([user: user], user.is_banned == false)
    |> preload([game, user: user], user: user)
    |> Repo.get(game_id)
    |> case do
      %Game{} = game ->
        {:ok, game}

      _result ->
        {:error, :not_found}
    end
  end

  @spec delete_game(integer(), integer()) :: {:ok, Game.t()} | {:error, Ecto.Changeset.t()}

  def delete_game(game_id, user_id) do
    Game
    |> where([g], g.user_id == ^user_id)
    |> Repo.get(String.to_integer(game_id))
    |> Repo.delete()
  end
end

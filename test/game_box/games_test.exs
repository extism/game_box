defmodule GameBox.GamesTest do
  @moduledoc false

  use GameBox.DataCase
  alias GameBox.Games

  setup do
    user = insert(:user)
    _game1 = insert(:game)
    game2 = insert(:game, user: user)

    {:ok, game2: game2, user: user}
  end

  describe "list_games_for_user/1" do
    test "only returns games for the user who created them", %{game2: %{id: game_id}, user: user} do
      assert [%{id: ^game_id}] = Games.list_games_for_user(user.id)
    end
  end

  describe "list_games/0" do
    test "returns all games that were not uploaded by a banned user" do
      _banned_game = insert(:game, user: insert(:user, is_banned: true))
      games = Games.list_games()
      assert Enum.count(games) == 2
    end
  end

  describe "get_game/1" do
    test "returns a game or not_found", %{game2: %{id: game_id}} do
      assert {:ok, %{id: ^game_id}} = Games.get_game(game_id)
      assert {:error, :not_found} = Games.get_game(0)
    end
  end
end

defmodule GameBoxWeb.ArenaLive do
  use GameBoxWeb, :live_view

  alias Phoenix.PubSub
  alias GameBox.Arena

  def render(assigns) do
    ~H"""
    <h1>Arena</h1>
    <p>Current Player: <%= @player.name %></p>
    <p>Players Online</p>
    <ul>
      <li :for={player <- @arena.players}><%= player.name %></li>
    </ul>

    <h2>Choose a game to start playing</h2>
    <ul>
      <li :for={game <- @games}><%= game.title %></li>
    </ul>
    """
  end

  def mount(params, _session, socket) do
    %{"code" => code, "player_id" => player_id} = params

    if connected?(socket) do
      PubSub.subscribe(GameBox.PubSub, "arena:#{code}")
      send(self(), :load_game_state)
    end

    {:ok,
     assign(socket,
       games: GameBox.Games.list_games(),
       arena_code: code,
       player_id: player_id,
       player: %Arena.Player{},
       arena: %Arena.State{},
       server_found: Arena.Server.server_found?(code)
     )}
  end

  def handle_info(:load_game_state, socket) do
    %{assigns: %{arena_code: code, player_id: player_id}} = socket

    state = Arena.Server.game_state(code)
    player = Arena.State.get_player(state, player_id)

    {:noreply, assign(socket, arena: state, player: player)}
  end

  def handle_info({:arena_state, state}, socket) do
    {:noreply, assign(socket, arena: state)}
  end

  def terminate(_reason, socket) do
    %{assigns: %{arena: arena, player: player}} = socket
    Arena.Server.leave_arena(arena.code, player)
  end
end

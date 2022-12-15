defmodule GameBoxWeb.ArenaLive do
  use GameBoxWeb, :live_view

  alias GameBox.Arena
  alias GameBox.Games
  alias GameBox.Players
  alias Phoenix.PubSub

  def render(assigns) do
    %{arena: arena, current_player: current_player} = assigns
    arena_id = arena[:arena_id]
    board =
      Arena.render_game(arena_id, %{
        player_id: current_player[:name],
      })
    #board = ""


    ~H"""
    <h1>Arena</h1>
    <p>Current Player: <%= @current_player.name %></p>
    <p>Players Online</p>
    <ul>
      <li :for={player <- @other_players}>
        <%= player.name %>
      </li>
    </ul>

    <h2>Choose a game to start playing</h2>
    <ul>
      <li :for={game <- @games}>
        <button phx-click="start_game" phx-value-game_id={game.id}><%= game.title %></button>
      </li>
    </ul>

    <hr />

    <div id="board">
      <%= Phoenix.HTML.raw(board) %>
    </div>
    """
  end

  def mount(params, _session, socket) do
    IO.puts "Mounting"
    %{"arena_id" => arena_id} = params
    %{assigns: %{player_id: player_id}} = socket

    if connected?(socket) do
      PubSub.subscribe(GameBox.PubSub, "arena:#{arena_id}")
      send(self(), :load_game_state)
    end

    if Players.exists?(arena_id) and Arena.exists?(arena_id) do
      players = Players.list_players(arena_id)
      current_player = Map.get(players, player_id)
      other_players = players |> Map.delete(player_id) |> Map.values()

      {:ok,
       assign(socket,
         current_player: current_player,
         other_players: other_players,
         arena: Arena.state(arena_id),
         games: Games.list_games(),
         version: -1
       )}
    else
      IO.puts "push nav"
      {:ok, push_navigate(socket, to: ~p"/")}
    end
  end

  def handle_event("start_game", %{"game_id" => game_id}, socket) do
    IO.puts "start game"
    IO.inspect socket
    IO.inspect game_id
    %{assigns: %{arena: %{arena_id: arena_id}}} = socket
    IO.puts "load game"
    IO.inspect game_id
    :ok = Arena.load_game(arena_id, game_id)
    {:noreply, socket}
  end

  def handle_event(message, params, socket) do
    %{assigns: %{arena: %{arena_id: arena_id}, current_player: %{name: player_name}}} = socket

    event = %{
      player_id: player_name,
      event_name: message,
      value: params
    }

    response = Arena.new_event(arena_id, event)
    IO.puts "handle event"
    IO.inspect(response)

    socket =
      if is_nil(response[:error]) do
        socket
      else
        put_flash(socket, :error, response.error)
      end

    Arena.broadcast_game_state(%{arena_id: arena_id, version: response.version})
    {:noreply, assign(socket, :version, response.version)}
  end

  def handle_info(:game_started, socket) do
    IO.puts ":game_started"
    #%{assigns: %{arena: %{arena_id: arena_id}, current_player: %{name: player_name}}} = socket
    {:noreply, assign(socket, version: 0)}
  end

  def handle_info(:load_game_state, %{assigns: %{server_found?: false}} = socket) do
    IO.puts ":load_game_state"
    {:noreply, push_navigate(socket, to: ~p"/")}
  end

  def handle_info({:arena_state, state}, socket) do
    IO.puts ":arena_state"
    {:noreply, assign(socket, arena: state)}
  end

  def handle_info({:version, version}, socket) do
    IO.puts ":version_bump"
    {:noreply, assign(socket, version: version)}
  end

  def handle_info(_message, socket) do
    IO.puts ":default"
    {:noreply, socket}
  end
end

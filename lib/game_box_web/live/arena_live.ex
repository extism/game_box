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

    ~H"""
    <h1>Arena</h1>
    <p>
      Current Player<br />
      <%= @current_player.name %><br />
      <%= @current_player.pids |> Enum.map(&inspect/1) |> Enum.join(" ") %>
    </p>
    <p>Players Online</p>
    <ul>
      <li :for={player <- @other_players}>
        <%= player.name %><br />
        <%= player.pids |> Enum.map(&inspect/1) |> Enum.join(" ") %>
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
    %{"arena_id" => arena_id} = params
    %{assigns: %{player_id: player_id}} = socket

    if connected?(socket) do
      PubSub.subscribe(GameBox.PubSub, "arena:#{arena_id}")
      Players.monitor(arena_id, player_id)
    end

    if Players.exists?(arena_id) and Arena.exists?(arena_id) do
      {:ok,
       socket
       |> assign(:arena, Arena.state(arena_id))
       |> assign(:games, Games.list_games())
       |> assign(:board, nil)
       |> assign(:version, 0)
       |> assign(:player_id, player_id)
       |> assign_current_player()
       |> assign_other_players()}
    else
      {:ok, push_navigate(socket, to: ~p"/")}
    end
  end

  def handle_event("start_game", %{"game_id" => game_id}, socket) do
    %{assigns: %{arena: %{arena_id: arena_id}}} = socket
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
    #%{assigns: %{arena: %{arena_id: arena_id}, current_player: %{name: player_name}}} = socket
    {:noreply, assign(socket, version: 0)}
  end

  def handle_info(:load_game_state, %{assigns: %{server_found?: false}} = socket) do
    {:noreply, push_navigate(socket, to: ~p"/")}
  end

  def handle_info({:arena_state, state}, socket) do
    {:noreply, assign(socket, arena: state)}
  end

  def handle_info({:version, version}, socket) do
    {:noreply, assign(socket, version: version)}
  end

  def handle_info(:players_updated, socket) do
    {:noreply, assign_other_players(socket)}
  end

  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  defp assign_current_player(socket) do
    %{assigns: %{arena: %{arena_id: arena_id}, player_id: player_id}} = socket

    assign(socket, current_player: Players.get_player(arena_id, player_id))
  end

  defp assign_other_players(socket) do
    %{assigns: %{arena: %{arena_id: arena_id}, player_id: player_id}} = socket

    other_players =
      arena_id
      |> Players.list_players()
      |> Map.delete(player_id)
      |> Map.values()

    assign(socket, :other_players, other_players)
  end
end

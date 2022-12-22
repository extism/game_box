defmodule GameBoxWeb.ArenaLive do
  use GameBoxWeb, :live_view
  require Logger

  alias GameBox.Arena
  alias GameBox.Games
  alias GameBox.Players
  alias Phoenix.PubSub

  def render(assigns) do
    ~H"""
    <h1>Arena</h1>
    <p>
      Current Player: <%= @current_player.name %>
    </p>
    <p>Players Online</p>
    <ul>
      <li :for={player <- @other_players}>
        <%= player.name %>
      </li>
    </ul>

    <h2>Choose a game to start playing</h2>
    <ul id="games">
      <li :for={game <- @games}>
        <button phx-click="start_game" phx-value-game_id={game.id}><%= game.title %></button>
      </li>
    </ul>

    <hr />

    <div id="board">
      <%= Phoenix.HTML.raw(@board) %>
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
       |> assign(:player_id, player_id)
       |> assign(:game_state, Arena.game_state(arena_id, player_id))
       |> assign_rendered_board()
       |> assign_current_player()
       |> assign_other_players()}
    else
      {:ok, push_navigate(socket, to: ~p"/")}
    end
  end

  def handle_event("start_game", %{"game_id" => game_id}, socket) do
    %{assigns: %{arena: %{arena_id: arena_id}, current_player: %{id: player_id}}} = socket

    game_state = Arena.load_game(arena_id, game_id, player_id)
    board = Arena.render_game(arena_id, game_state)

    {:noreply,
      socket
      |> assign(:game_state, game_state)
      |> assign(:board, board)}
  end

  def handle_event(message, params, socket) do
    %{assigns: %{arena: %{arena_id: arena_id}, current_player: %{name: player_name}}} = socket

    event = %{
      player_id: player_name,
      event_name: message,
      value: params
    }

    Logger.info("Got LiveView Event #{inspect(event)}")

    case Arena.new_event(arena_id, event) do
      {:error, err} ->
        {:noreply, put_flash(socket, :error, err)}

      {:ok, game_state} ->
        IO.inspect(game_state, label: "5a21da9d-b67d-48d5-93cc-75c6137954db")
        board = Arena.render_game(arena_id, game_state)

        {:noreply,
          socket
          |> assign(:game_state, game_state)
          |> assign(:board, board)}
    end
  end

  def handle_info(:players_updated, socket) do
    {:noreply,
      socket
      |> assign_current_player()
      |> assign_other_players()}
  end

  def handle_info(:game_started, socket) do
    %{assigns: %{arena: %{arena_id: arena_id}, player_id: player_id}} = socket
    game_state = Arena.game_state(arena_id, player_id)

    {:noreply,
    socket
    |> assign(:game_state, game_state)
    |> assign_rendered_board()}
  end

  def handle_info(:game_update, socket) do
    %{assigns: %{arena: %{arena_id: arena_id}, game_state: game_state}} = socket
    board = Arena.render_game(arena_id, game_state)
    {:noreply, socket
    |> assign(:game_state, game_state)
    |> assign(:board, board)}
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

  def assign_rendered_board(socket) do
    %{assigns: %{arena: %{arena_id: arena_id}, game_state: game_state}} = socket
    board = Arena.render_game(arena_id, game_state)

    assign(socket, :board, board)
  end
end

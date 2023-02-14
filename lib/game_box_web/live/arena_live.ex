defmodule GameBoxWeb.ArenaLive do
  use GameBoxWeb, :live_view
  require Logger

  alias GameBox.Arena
  alias GameBox.Games
  alias GameBox.Players
  alias Phoenix.PubSub

  def mount(%{"arena_id" => arena_id}, _session, %{assigns: %{player_id: player_id}} = socket) do
    if connected?(socket) do
      PubSub.subscribe(GameBox.PubSub, "arena:#{arena_id}")
      Players.monitor(arena_id, player_id)
    end

    ready? = Players.exists?(arena_id) and Arena.exists?(arena_id)
    game_id = Arena.get_game(arena_id)

    socket =
      cond do
        ready? and game_id ->
          constraints = Arena.get_constraints(arena_id, game_id)
          {:ok, game} = Games.get_game(game_id)

          socket
          |> assign(:constraints, constraints)
          |> assign(:game_selected, game)
          |> set_defaults(arena_id, player_id)

        ready? ->
          socket
          |> assign(:game_selected, nil)
          |> set_defaults(arena_id, player_id)

        true ->
          push_navigate(socket, to: Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.HomeLive))
      end

    {:ok, socket}
  end

  def render(assigns) do
    # NOTE: don't put this in the heex template or it will be cached
    # ignore warnings from phoenix
    board = render_board(assigns[:arena][:arena_id], assigns[:current_player][:name])

    ~H"""
    <%= if board == "" do %>
      <h1>Arena: <%= @arena.arena_id %></h1>

      <hr />
      <h2><%= @current_player.name %></h2>
      <%= if @is_host && @game_selected do %>
        <button phx-click="unselect_game" phx-value-game_id={@game_selected.id}>Unselect Game</button>
        <%= if can_start_game?(assigns) do %>
          <button phx-click="start_game" phx-value-game_id={@game_selected.id}>Start Game</button>
        <% end %>
      <% end %>
      <%= if @is_host && is_nil(@game_selected) do %>
        <%= if is_nil(@game_selected) do %>
          <h2>Choose a game to start playing</h2>
          <ul>
            <div class="grid grid-cols-4 gap-4">
              <%= for game <- @games do %>
                <button phx-click="select_game" phx-value-game_id={game.id}><%= game.title %></button>
              <% end %>
            </div>
          </ul>
        <% end %>
      <% end %>
      <%= if @game_selected && !@game_started do %>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <div>
              <p>
                <strong>Player count: </strong>
                <%= @total_players %>-<%= get_in(assigns, [:constraints, :min_players]) %>
              </p>
            </div>
            <p>Online Players</p>
            <ul>
              <li><%= @current_player.name %></li>
              <li :for={player <- @other_players}>
                <%= player.name %>
              </li>
            </ul>
          </div>
          <div>
            <p>
              <strong>Title: </strong>
              <%= @game_selected.title %>
            </p>
            <p><strong>How to play: </strong><%= @game_selected.description %></p>
            <img src={Routes.static_path(GameBoxWeb.Endpoint, "/uploads/#{@game_selected.artwork}")} />
            <p><strong>Creator: </strong><%= @game_selected.user.gh_login %></p>
          </div>
        </div>
      <% end %>
    <% else %>
      <%= if @is_host && @game_selected do %>
        <button phx-click="unselect_game" phx-value-game_id={@game_selected.id}>Unselect Game</button>
      <% end %>
      <div id="board">
        <%= Phoenix.HTML.raw(board) %>
      </div>
    <% end %>
    """
  end

  def handle_event(
        "select_game",
        %{"game_id" => game_id},
        %{assigns: %{arena: %{arena_id: arena_id}}} = socket
      ) do
    case Arena.set_game(arena_id, game_id) do
      {:ok, _game_id} ->
        {:noreply, socket}

      _result ->
        {:noreply, put_flash(socket, :error, "could not select game")}
    end
  end

  def handle_event(
        "unselect_game",
        %{"game_id" => game_id},
        %{assigns: %{arena: %{arena_id: arena_id}, is_host: true}} = socket
      ) do
    case Arena.unset_game(arena_id, game_id) do
      {:ok, _arena_id} ->
        {:noreply, put_flash(socket, :info, "Game unset")}

      _ ->
        {:noreply, put_flash(socket, :error, "Game not unset")}
    end
  end

  def handle_event(
        "unselect_game",
        _params,
        socket
      ) do
    {:noreply, put_flash(socket, :error, "Only host can unset game")}
  end

  def handle_event("start_game", %{"game_id" => game_id}, socket) do
    %{assigns: %{arena: %{arena_id: arena_id}}} = socket
    num_players = player_count(arena_id)
    constraints = Arena.get_constraints(arena_id, game_id)

    cond do
      num_players < constraints[:min_players] ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "Not enough players to start game. Need at least " <>
             to_string(constraints[:min_players])
         )}

      num_players > constraints[:max_players] ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "Too many players. Can have no more than " <> to_string(constraints[:max_players])
         )}

      true ->
        :ok = Arena.load_game(arena_id, game_id)
        Arena.broadcast_game_state(%{arena_id: arena_id, version: 0})
        {:noreply, socket}
    end
  end

  def handle_event(message, params, socket) do
    %{assigns: %{arena: %{arena_id: arena_id}, current_player: %{name: player_name}}} = socket

    event = %{
      player_id: player_name,
      event_name: message,
      value: params
    }

    Logger.info("Got LiveView Event #{inspect(event)}")

    socket =
      case Arena.new_event(arena_id, event) do
        {:error, err} ->
          socket
          |> put_flash(:error, err)
          |> assign(:version, socket.assigns[:version] + 1)

        {:ok, assigns} ->
          socket
          |> clear_flash
          |> assign(assigns)
      end

    Logger.info("Broadcasting State Change #{inspect(socket.assigns[:version])}")
    Arena.broadcast_game_state(%{arena_id: arena_id, version: socket.assigns[:version]})
    {:noreply, socket}
  end

  def handle_info(:game_started, socket) do
    Logger.info("Game started")
    {:noreply, assign(socket, version: 0)}
  end

  def handle_info(:game_selected, %{assigns: %{arena: %{arena_id: arena_id}}} = socket) do
    game_id = Arena.get_game(arena_id)
    constraints = Arena.get_constraints(arena_id, game_id)

    {:ok, game} = Games.get_game(game_id)

    socket =
      socket
      |> assign(:game_selected, game)
      |> assign(:constraints, constraints)

    {:noreply, socket}
  end

  def handle_info(:game_unselected, socket) do
    socket =
      socket
      |> assign(:game_selected, nil)
      |> assign(:constraints, nil)
      |> assign(:version, -1)

    {:noreply, socket}
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

  defp set_defaults(socket, arena_id, player_id) do
    socket
    |> assign(:arena, Arena.state(arena_id))
    |> assign(:games, Games.list_games())
    |> assign(:version, -1)
    |> assign(:player_id, player_id)
    |> assign(:is_host, Arena.get_host(arena_id) == player_id)
    |> assign_new(:game_started, fn -> false end)
    |> assign_new(:game_selected, fn -> nil end)
    |> assign_current_player()
    |> assign_other_players()
  end

  defp assign_current_player(socket) do
    %{assigns: %{arena: %{arena_id: arena_id}, player_id: player_id}} = socket

    assign(socket, current_player: Players.get_player(arena_id, player_id))
  end

  defp assign_other_players(socket) do
    %{assigns: %{arena: %{arena_id: arena_id}, player_id: player_id}} = socket

    players = Players.list_players(arena_id)

    other_players =
      players
      |> Map.delete(player_id)
      |> Map.values()

    socket
    |> assign(:other_players, other_players)
    |> assign(:total_players, Enum.count(players))
  end

  defp player_count(arena_id) do
    arena_id
    |> Players.list_players()
    |> Map.values()
    |> Enum.count()
  end

  def can_start_game?(%{constraints: %{min_players: min_players}, total_players: total_players}) do
    total_players >= min_players
  end

  def can_start_game?(_), do: false

  defp render_board(arena_id, player_id) do
    Arena.render_game(arena_id, %{
      player_id: player_id
    })
  end
end

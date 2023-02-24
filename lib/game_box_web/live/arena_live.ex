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

    arena = Arena.exists?(arena_id)
    arena_state = Arena.state(arena_id)
    ready? = arena and Players.exists?(arena_id)
    game_id = arena && Arena.get_game(arena_id)

    socket =
      cond do
        ready? and game_id ->
          socket
          |> assign(:constraints, arena_state.constraints)
          |> assign(:game_selected, arena_state.game)
          |> set_defaults(arena_id, player_id)

        ready? ->
          socket
          |> assign(:game_selected, nil)
          |> set_defaults(arena_id, player_id)

        true ->
          socket
          |> put_flash(:error, "Looks like that arena does not exist or you have not joined it!")
          |> push_navigate(to: Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.HomeLive))
      end

    {:ok, socket}
  end

  def render(assigns) do
    # NOTE: don't put this in the heex template or it will be cached
    # ignore warnings from phoenix
    board = render_board(assigns[:arena][:arena_id], assigns[:current_player][:name])

    ~H"""
    <%= if board == "" do %>
      <.hero
        subheader="Arena"
        header={@arena.arena_id}
        subtext={populateSubtext(@game_selected, @is_host)}
      />
      <%= if is_nil(@game_selected) do %>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-x-12 gap-y-12 mb-12">
          <%= for game <- @games do %>
            <.card>
              <.card_media :if={game.artwork} src={game.artwork} />
              <.card_media
                :if={!game.artwork}
                src="/images/donut.png"
                class="flex justify-center w-48 p-6"
              />
              <.card_content
                author={"@#{game.user.gh_login}"}
                author_link={"https://github.com/@#{game.user.gh_login}"}
                heading={game.title}
              />
              <.card_footer>
                <%= if @is_host do %>
                  <.button
                    phx-click="select_game"
                    phx-value-game_id={game.id}
                    label="Start"
                    class="w-full"
                  />
                <% end %>
              </.card_footer>
            </.card>
          <% end %>
        </div>
      <% end %>
      <%= if @game_selected && !@game_started do %>
        <div class="pt-4">
          <div class="flex align-center">
            <.h4 label="Waiting to Play:" />
            <.h4 class="pl-4" label={@game_selected.title} />
          </div>

          <div class="flex row gap-x-8 mt-8">
            <div class="basis-2/3">
              <img class="aspect-square" src={@game_selected.artwork} />
              <div class="mt-12">
                <.h4>How to play:</.h4>
                <.p><%= @game_selected.description %></.p>
              </div>
              <.card class="mt-12">
                <.card_content>
                  <.h4>Credits</.h4>
                  <.p>
                    Game and instructions by
                    <.link href={"https://github.com/#{@game_selected.user.gh_login}"}>
                      @<%= @game_selected.user.gh_login %>
                    </.link>
                  </.p>
                </.card_content>
              </.card>
            </div>
            <div class="basis-1/3">
              <.card>
                <.card_content>
                  <div>
                    <.h4 label="Details" />
                    <.p>
                      Player count: <%= @total_players %> out of <%= @constraints.min_players %>-<%= @constraints.max_players %>
                    </.p>
                  </div>
                  <.card>
                    <.card_content>
                      <.p class="font-bold">Online Players</.p>
                      <.ol>
                        <li :for={player <- @all_players}>
                          <%= player.name %>
                        </li>
                      </.ol>
                    </.card_content>
                  </.card>
                  <%= unless can_start_game?(assigns) do %>
                    <.p class="text-center">Waiting on more players...</.p>
                  <% end %>
                </.card_content>
                <.card_footer>
                  <%= if @is_host && @game_selected do %>
                    <.button
                      phx-click="unselect_game"
                      phx-value-game-id={@game_selected.id}
                      variant="outline"
                      label="Lobby"
                      class="w-full"
                    />

                    <%= if can_start_game?(assigns) do %>
                      <.button
                        phx-click="start_game"
                        phx-value-game-id={@game_selected.id}
                        label="Start Game"
                        class="w-full"
                      />
                    <% end %>
                  <% end %>
                </.card_footer>
              </.card>
            </div>
          </div>
        </div>
      <% end %>
    <% else %>
      <%= if @is_host && @game_selected do %>
        <%= if @missing_players do %>
          <.p>
            All of the players who began this game are no longer present. Please return to the lobby to reselect a game.
          </.p>
        <% end %>
        <.button
          phx-click="unselect_game"
          phx-value-game-id={@game_selected.id}
          variant="outline"
          label="Lobby"
        />
      <% end %>
      <div id="board">
        <%= Phoenix.HTML.raw(board) %>
      </div>
    <% end %>
    """
  end

  def handle_event(
        "select_game",
        %{"game-id" => game_id},
        %{assigns: %{arena: %{arena_id: arena_id}}} = socket
      ) do
    case Arena.set_game(arena_id, game_id) do
      {:ok, _game_id} ->
        PubSub.broadcast(GameBox.PubSub, "arena:#{arena_id}", :game_selected)

        {:noreply, socket}

      _result ->
        {:noreply, put_flash(socket, :error, "could not select game")}
    end
  end

  def handle_event(
        "unselect_game",
        %{"game-id" => game_id},
        %{assigns: %{arena: %{arena_id: arena_id}, is_host: true}} = socket
      ) do
    case Arena.unset_game(arena_id, game_id) do
      {:ok, _arena_id} ->
        {:noreply, socket}

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

  def handle_event("start_game", %{"game-id" => game_id}, socket) do
    %{
      assigns: %{
        arena: %{arena_id: arena_id},
        total_players: num_players,
        constraints: %{min_players: min_players}
      }
    } = socket

    if num_players < min_players do
      {:noreply,
       put_flash(
         socket,
         :error,
         "Not enough players to start game. Need at least " <>
           to_string(min_players)
       )}
    else
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

  def handle_info(:game_started, %{assigns: %{arena: %{arena_id: arena_id}}} = socket) do
    Logger.info("Game started")

    socket =
      socket
      |> assign(:version, 0)
      |> assign(:arena, Arena.state(arena_id))
      |> assign(:missing_players, false)

    {:noreply, socket}
  end

  def handle_info(:game_selected, %{assigns: %{arena: %{arena_id: arena_id}}} = socket) do
    %{game: game} = Arena.state(arena_id)

    constraints = Arena.get_constraints(arena_id)

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

  # Each time the players are updated, if the process
  # receiving the message belongs to the host, we want to send a check in 5 seconds that
  # ensures that all the players who began the game are still in the room. The reason
  # we wait 5 seconds is to allow time for a page refresh or quick navigation away and
  # back before showing this message to the host.
  def handle_info(
        :players_updated,
        %{assigns: %{is_host: true, arena: %{playing: [_head | _tail]}}} = socket
      ) do
    if connected?(socket), do: Process.send_after(self(), :check_for_missing_players, 5000)

    {:noreply, assign_all_players(socket)}
  end

  def handle_info(:players_updated, socket) do
    {:noreply, assign_all_players(socket)}
  end

  def handle_info(
        :check_for_missing_players,
        %{assigns: %{arena: %{arena_id: arena_id, playing: playing}}} = socket
      ) do
    player_ids =
      arena_id
      |> Players.list_players()
      |> Map.values()
      |> Enum.map(& &1.id)

    missing_players = Enum.any?(playing, &(not Enum.member?(player_ids, &1)))

    {:noreply, assign(socket, :missing_players, missing_players)}
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
    |> assign_new(:constraints, fn -> %{} end)
    |> assign(:missing_players, false)
    |> assign_current_player()
    |> assign_all_players()
  end

  defp assign_current_player(socket) do
    %{assigns: %{arena: %{arena_id: arena_id}, player_id: player_id}} = socket

    assign(socket, current_player: Players.get_player(arena_id, player_id))
  end

  def assign_all_players(%{assigns: %{arena: %{arena_id: arena_id}}} = socket) do
    players =
      arena_id
      |> Players.list_players()
      |> Map.values()
      |> Enum.sort(&(&1.joined_at < &2.joined_at))

    socket
    |> assign(:all_players, players)
    |> assign(:total_players, Enum.count(players))
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

  defp populateSubtext(game_selected, is_host) do
    if is_nil(game_selected) do
      if is_host do
        "Select a game to get started!"
      else
        "Waiting for the host to select a game..."
      end
    end
  end
end

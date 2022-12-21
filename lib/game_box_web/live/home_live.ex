defmodule GameBoxWeb.HomeLive do
  use GameBoxWeb, :live_view

  alias GameBox.Arena
  alias GameBox.Games
  alias GameBox.Players

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container join-arena-form">
      <h2>Start or Join an Arena</h2>
      <form id="join_arena" phx-submit="join_arena">
        <div class="mb-3">
          <label for="player_name">Name</label>
          <input
            class="form-control"
            type="text"
            id="player_name"
            name="player_name"
            placeholder="Enter user name"
          />
        </div>
        <div class="mb-3">
          <label for="arena_id">Arena Code</label>
          <input
            type="text"
            class="form-control"
            id="arena_id"
            name="arena_id"
            placeholder="4 character arena code"
          />
        </div>

        <button type="submit" class="btn btn-primary">Join Arena</button>
      </form>
    </div>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(GameBox.PubSub, "games")
    end

    {:ok,
     socket
     |> assign(:player_id, session["player_id"])}
  end

  @impl true
  def handle_event("join_arena", unsigned_params, socket) do
    %{"player_name" => player_name, "arena_id" => arena_id} = unsigned_params

    if String.length(arena_id) != 4 do
      {:noreply, put_flash(socket, :error, "Arena code should be exactly 4 characters")}
    else
      %{assigns: %{player_id: player_id}} = socket
      player_params = %{name: player_name, arena_id: arena_id}
      :ok = Arena.start(arena_id)
      :ok = Players.start(arena_id)

      case Players.register_player(arena_id, player_id, player_params) do
        {:ok, _player} ->
          {:noreply, push_redirect(socket, to: ~p"/arena/#{arena_id}")}

        {:error, %Ecto.Changeset{}} ->
          {:noreply, put_flash(socket, :error, "Invalid data was received.")}

        {:error, msg} ->
          {:noreply, put_flash(socket, :error, msg)}
      end
    end
  end

  def handle_event("validate", _unsigned_params, socket) do
    {:noreply, socket}
  end

  def handle_event("validate_join", unsigned_params, socket) do
    %{"arena_id" => arena_id, "player_name" => player_name} = unsigned_params
    {:noreply, assign(socket, arena_id: arena_id, player_name: player_name)}
  end

  @impl true
  def handle_info({:games, games}, socket) do
    {:noreply, assign(socket, games: games)}
  end
end

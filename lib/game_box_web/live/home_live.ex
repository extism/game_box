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

      <h2>Upload a Game</h2>
      <form id="upload_game" phx-submit="upload_game" phx-change="validate">
        <%= live_file_input(@uploads.game, name: "Test") %>

        <%= unless Enum.empty?(@uploads.game.entries) do %>
          <label>
            <span>Title</span>
            <input type="text" name="title" />
          </label>
        <% end %>
        <button>Submit</button>
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
     |> assign(:uploaded_files, [])
     |> assign(:games, Games.list_games())
     |> assign(:player_id, session["player_id"])
     |> allow_upload(:game, accept: ~w(.wasm), max_entries: 2, max_file_size: 100_000_000)}
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

  def handle_event("upload_game", unsigned_params, socket) do
    disk_volume_path = Application.get_env(:game_box, :disk_volume_path)

    [path] =
      consume_uploaded_entries(socket, :game, fn %{path: path}, _entry ->
        dest = Path.join([disk_volume_path, Path.basename(path)])
        File.cp!(path, dest)
        {:ok, Path.basename(path)}
      end)

    {:ok, _game} =
      unsigned_params
      |> Map.put("path", path)
      |> Games.create_game()

    Phoenix.PubSub.broadcast(GameBox.PubSub, "games", {:games, Games.list_games()})

    {:noreply, socket}
  end

  @impl true
  def handle_info({:games, games}, socket) do
    {:noreply, assign(socket, games: games)}
  end
end

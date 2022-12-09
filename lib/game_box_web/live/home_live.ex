defmodule GameBoxWeb.HomeLive do
  use GameBoxWeb, :live_view

  alias GameBox.Games

  def render(assigns) do
    ~H"""
    <h1>Game Box</h1>

    <h2>Games</h2>
    <ul>
      <li :for={game <- @games}><%= game.title %></li>
    </ul>

    <h2>Start or Join an Arena</h2>
    <form id="join_arena" phx-submit="join_arena">
      <label>
        <span>Player Name</span>
        <input type="text" name="player_name" />
      </label>
      <label>
        <span>Arena Code</span>
        <input type="text" name="arena_code" />
      </label>
      <button>Submit</button>
    </form>

    <h2>Upload a Game</h2>
    <form id="upload_game" phx-submit="upload_game" phx-change="validate">
      <%= live_file_input @uploads.game, name: "Test" %>

      <%= unless Enum.empty?(@uploads.game.entries) do %>
        <label>
          <span>Title</span>
          <input type="text" name="title" />
        </label>
      <% end %>
      <button>Submit</button>
    </form>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
    socket
    |> assign(:uploaded_files, [])
    |> assign(:games, Games.list_games())
    |> allow_upload(:game, accept: ~w(.wasm), max_entries: 2, max_file_size: 100_000_000)}
  end

  def handle_event("join_arena", unsigned_params, socket) do
    %{"player_name" => player_name, "arena_code" => arena_code} = unsigned_params
    player = GameBox.Arena.Player.new(player_name)
    {:ok, _started_or_joined} = GameBox.Arena.Server.start_or_join(arena_code, player)
    {:noreply, push_redirect(socket, to: ~p"/arena?code=#{arena_code}&player_id=#{player.id}")}
  end

  def handle_event("validate", _unsigned_params, socket) do
    {:noreply, socket}
  end

  def handle_event("upload_game", unsigned_params, socket) do
    [path] =
      consume_uploaded_entries(socket, :game, fn %{path: path}, _entry ->
        dest = Path.join([:code.priv_dir(:game_box), "static", "uploads", Path.basename(path)])
        File.cp!(path, dest)
        {:ok, ~p"/uploads/#{Path.basename(dest)}"}
      end)

      {:ok, _game} =
        unsigned_params
        |> Map.put("path", path)
        |> IO.inspect()
        |> Games.create_game()

    {:noreply, socket}
  end
end

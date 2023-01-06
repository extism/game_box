defmodule GameBoxWeb.UploadLive do
  use GameBoxWeb, :live_view

  alias GameBox.Games

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container join-arena-form">
      <h2>Upload a Game</h2>
      <form id="upload_game" phx-submit="upload_game" phx-change="validate">
        <%= live_file_input(@uploads.game, name: "Test") %>

        <%= unless Enum.empty?(@uploads.game.entries) do %>
          <label>
            <span>Title</span>
            <input type="text" name="title" />
          </label>
          <label>
            <span>Password</span>
            <input type="password" name="password" />
          </label>
        <% end %>
        <button>Submit</button>
      </form>
      <ul>
        <li :for={game <- @games}>
          <p><%= game.title %></p>
        </li>
      </ul>
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
     |> allow_upload(:game, accept: ~w(.wasm), max_entries: 2, max_file_size: 100_000_000)}
  end

  def handle_event("validate", _unsigned_params, socket) do
    {:noreply, socket}
  end

  def handle_event("upload_game", unsigned_params, socket) do
    password = Map.get(unsigned_params, "password")
    if Application.get_env(:game_box, :password) != password do
      {:noreply, put_flash(socket, :error, "Incorrect password")}
    else
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

      {:noreply, clear_flash(socket)}
    end
  end

  @impl true
  def handle_info({:games, games}, socket) do
    {:noreply, assign(socket, games: games)}
  end
end

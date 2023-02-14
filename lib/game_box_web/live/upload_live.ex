defmodule GameBoxWeb.UploadLive do
  use GameBoxWeb, :live_view

  alias GameBox.Games
  alias GameBox.Games.Game

  @disk_volume_path Application.compile_env(:game_box, :disk_volume_path)
  @max_file_size 100_000_000

  @impl true
  @spec mount(any, map, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, %{"user_id" => user_id}, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(GameBox.PubSub, "games")
    end

    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> assign(:artwork_files, [])
     |> assign(:changeset, Game.changeset(%Game{}, %{}))
     |> assign(:user_id, user_id)
     |> assign(:games, Games.list_games_for_user(user_id))
     |> allow_upload(:game, accept: ~w(.wasm), max_file_size: @max_file_size)
     |> allow_upload(:artwork, accept: ~w(.jpg .jpeg .png))}
  end

  @impl true
  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="container join-arena-form">
      <.h2>Upload a Game</.h2>
      <.simple_form
        :let={f}
        id="upload-game-form"
        for={@changeset}
        phx-change="validate"
        phx-submit="upload_game"
      >
        <.input field={{f, :title}} label="Title" />

        <.input field={{f, :description}} label="Description" />

        <.live_file_input upload={@uploads.game} />

        <%= for err <- upload_errors(@uploads.game) do %>
          <p class="alert alert-danger"><%= error_to_string(err) %></p>
        <% end %>

        <.live_file_input upload={@uploads.artwork} />
        <%= for err <- upload_errors(@uploads.artwork) do %>
          <p class="alert alert-danger"><%= error_to_string(err) %></p>
        <% end %>
        <:actions>
          <.button type="submit" name="save">Save</.button>
        </:actions>
      </.simple_form>
      <div class="mt-8">
        <.h2>My Games</.h2>
        <ul>
          <li :for={game <- @games}>
            <p><%= game.title %></p>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"game" => params}, %{assigns: %{changeset: changeset}} = socket) do
    {:noreply, assign(socket, :changeset, Game.changeset(changeset, params))}
  end

  def handle_event(
        "upload_game",
        %{"game" => game_params},
        %{assigns: %{user_id: user_id}} = socket
      ) do
    %{artwork: artwork, game_path: game_path} = get_paths(socket)

    socket =
      game_params
      |> Map.merge(%{"path" => game_path, "user_id" => user_id, "artwork" => artwork})
      |> Games.create_game()
      |> case do
        {:ok, _game} ->
          Phoenix.PubSub.broadcast(GameBox.PubSub, "games", {:games, Games.list_games()})

          socket
          |> put_flash(:info, "Game successfully uploaded!")
          |> assign(:changeset, Game.changeset(%Game{}, %{}))
          |> assign(:games, Games.list_games_for_user(user_id))
          |> assign(:uploaded_files, [])
          |> assign(:artwork_files, [])

        {:error, %Ecto.Changeset{} = changeset} ->
          socket
          |> put_flash(:error, "Game could not be uploaded.")
          |> assign(:changeset, changeset)
      end

    {:noreply, socket}
  end

  defp get_paths(socket) do
    get_path = fn result ->
      case result do
        [path] -> path
        _ -> {:error, :no_files}
      end
    end

    art_result = handle_consume(socket, :artwork)
    game_result = handle_consume(socket, :game)

    %{artwork: get_path.(art_result), game_path: get_path.(game_result)}
  end

  defp handle_consume(socket, atom) do
    consume_uploaded_entries(socket, atom, fn %{path: path}, _entry ->
      dest = Path.join([@disk_volume_path, Path.basename(path)])

      case File.cp(path, dest) do
        :ok -> {:ok, Path.basename(path)}
        {:error, _} -> {:error, nil}
      end
    end)
  end

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  def error_to_string(:too_many_files), do: "You have selected too many files"
end

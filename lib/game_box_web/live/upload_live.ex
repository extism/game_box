defmodule GameBoxWeb.UploadLive do
  use GameBoxWeb, :live_view

  alias GameBox.Games
  alias GameBox.Games.Game
  alias GameBoxWeb.SimpleS3Upload

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
     |> assign(:uploaded_files, [])
     |> assign(:artwork_files, [])
     |> allow_upload(:game, accept: ~w(.wasm), max_file_size: @max_file_size)
     |> allow_upload(:artwork, accept: ~w(.jpg .jpeg .png), external: &presign_upload/2)}
  end

  @impl true
  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      <div class="p-8">
        <.h3 label="Tell us how to play your game" />

        <.simple_form
          :let={f}
          id="upload-game-form"
          for={@changeset}
          phx-change="validate"
          phx-submit="upload_game"
        >
          <div class="flex row gap-8">
            <div class="basis-2/3">
              <.input field={{f, :description}} type="textarea" placeholder="Write here..." />
            </div>
            <div class="basis-1/3">
              <.input field={{f, :title}} label="Title" />

              <.label>Upload game</.label>

              <.live_file_input upload={@uploads.game} />
              <%= for entry <- @uploads.game.entries do %>
                <article class="upload-entry">
                  <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>
                  <button
                    type="button"
                    phx-click="cancel-game-upload"
                    phx-value-ref={entry.ref}
                    aria-label="cancel"
                  >
                    &times;
                  </button>
                  <%= for err <- upload_errors(@uploads.game, entry) do %>
                    <.p class="alert alert-danger"><%= error_to_string(err) %></.p>
                  <% end %>
                </article>
              <% end %>

              <.label>Upload artwork</.label>
              <.live_file_input upload={@uploads.artwork} />
              <%= for entry <- @uploads.artwork.entries do %>
                <article class="upload-entry">
                  <figure>
                    <.live_img_preview entry={entry} />
                  </figure>

                  <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>

                  <button
                    type="button"
                    phx-click="cancel-art-upload"
                    phx-value-ref={entry.ref}
                    aria-label="cancel"
                  >
                    &times;
                  </button>

                  <%= for err <- upload_errors(@uploads.artwork, entry) do %>
                    <.p class="alert alert-danger"><%= error_to_string(err) %></.p>
                  <% end %>
                </article>
              <% end %>
              <.p class="mt-6">
                GameBox reserves the right to remove
                your game for any reason at any time.
                Please only submit content and games
                that are appropriate for all ages.
              </.p>

              <.button type="submit" name="save">Save game</.button>
            </div>
          </div>
        </.simple_form>
      </div>
      <div class="mt-8">
        <.h2 label="My Games" />
        <div class="grid grid-cols-4 gap-4 mt-4">
          <%= for game <- @games do %>
            <div class="p-4">
              <img class="object-contain h-48 w-48 rounded-lg" src={game.artwork} />
              <.p><%= game.title %></.p>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp presign_upload(entry, %{assigns: %{uploads: uploads}} = socket) do
    bucket = Application.get_env(:game_box, :s3_bucket)
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    key = "images/#{timestamp}-#{entry.client_name}"

    {:ok, fields} =
      SimpleS3Upload.sign_form_upload(bucket,
        key: key,
        content_type: entry.client_type,
        max_file_size: uploads[entry.upload_config].max_file_size,
        expires_in: :timer.hours(1)
      )

    object_path = "https://#{bucket}.s3.amazonaws.com/#{key}"

    meta = %{
      uploader: "S3",
      key: key,
      url: "https://#{bucket}.s3.amazonaws.com",
      fields: fields
    }

    {:ok, meta, assign(socket, :art_url, object_path)}
  end

  def handle_event("cancel-art-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :artwork, ref)}
  end

  def handle_event("cancel-game-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :game, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"game" => params}, %{assigns: %{changeset: changeset}} = socket) do
    {:noreply, assign(socket, :changeset, Game.changeset(changeset, params))}
  end

  def handle_event(
        "upload_game",
        %{"game" => game_params},
        socket
      ) do
    art_url = Map.get(socket.assigns, :art_url)
    user_id = Map.get(socket.assigns, :user_id)
    game_path = get_game_upload_path(socket)

    socket =
      game_params
      |> Map.merge(%{"path" => game_path, "user_id" => user_id, "artwork" => art_url})
      |> Games.create_game()
      |> case do
        {:ok, _game} ->
          Phoenix.PubSub.broadcast(GameBox.PubSub, "games", {:games, Games.list_games()})

          socket
          |> put_flash(:info, "Game successfully uploaded!")
          |> redirect(to: Routes.live_path(socket, GameBoxWeb.UploadLive))

        {:error, %Ecto.Changeset{} = changeset} ->
          socket
          |> put_flash(:error, "Game could not be uploaded.")
          |> assign(:changeset, changeset)
      end

    {:noreply, socket}
  end

  defp get_game_upload_path(socket) do
    disk_volume_path = Application.get_env(:game_box, :disk_volume_path)

    uploads =
      consume_uploaded_entries(socket, :game, fn %{path: path}, _entry ->
        dest = Path.join([disk_volume_path, Path.basename(path)])

        case File.cp(path, dest) do
          :ok -> {:ok, Path.basename(path)}
          {:error, _} -> {:error, nil}
        end
      end)

    case uploads do
      [path] -> path
      _ -> nil
    end
  end

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  def error_to_string(:too_many_files), do: "You have selected too many files"
  def error_to_string(:external_client_failure), do: "Upload failed"
  def error_to_string(_), do: "Unknown error"
end

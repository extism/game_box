defmodule GameBoxWeb.HomeLive do
  use GameBoxWeb, :live_view

  alias GameBox.Arena
  alias GameBox.Players

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.h2>Start or Join an Arena</.h2>
      <form id="join_arena" phx-submit="join_arena" class="flex flex-col w-1/4">
        <div>
          <.input
            label="Name"
            type="text"
            id="player_name"
            name="player_name"
            placeholder="Enter user name"
            class="w-full"
            value={@player_name}
            errors={["required"]}
          />
        </div>
        <div>
          <.input
            label="Arena Code"
            type="text"
            id="arena_id"
            name="arena_id"
            placeholder="4 character arena code"
            class="w-full"
            value=""
            errors={["required"]}
          />
        </div>
        <.button color="primary" type="submit">Join arena</.button>
      </form>
    </div>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    socket =
      socket
      |> assign_new(:player_name, fn -> "" end)
      |> assign_new(:arena_id, fn -> "" end)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(GameBox.PubSub, "games")
    end

    {:ok, assign(socket, :player_id, session["player_id"])}
  end

  @impl true
  def handle_event("join_arena", unsigned_params, socket) do
    %{"player_name" => player_name, "arena_id" => arena_id} = unsigned_params

    if String.length(arena_id) != 4 do
      {:noreply, put_flash(socket, :error, "Arena code should be exactly 4 characters")}
    else
      %{assigns: %{player_id: player_id}} = socket
      player_params = %{name: player_name, arena_id: arena_id}

      case Arena.start(arena_id) do
        {:ok, :initiated} ->
          Arena.set_host(arena_id, player_id)

        {:ok, :joined} ->
          nil
      end

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

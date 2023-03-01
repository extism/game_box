defmodule GameBoxWeb.StartLive do
  use GameBoxWeb, :live_view
  alias Ecto.Changeset
  alias GameBox.Arena
  alias GameBox.Players

  @arena_types %{
    player_name: :string,
    arena_id: :string
  }

  @impl true
  def render(assigns) do
    ~H"""
    <.hero class="pt-0 md:pt-16 !mb-0" header="Start an arena" />
    <div class="w-full flex justify-center">
      <.simple_form
        :let={f}
        id="join_arena"
        for={@changeset}
        as="arena_form"
        class="w-full md:w-2/3 lg:w-1/2"
        phx-change="validate"
        phx-submit="join_arena"
      >
        <div class="flex flex-col gap-y-6">
          <.input
            label="Name"
            type="text"
            id="player_name"
            field={{f, :player_name}}
            placeholder="Enter user name"
          />

          <%= if @changeset.valid? do %>
            <.button color="primary" type="submit" class="w-full">Generate Arena Code</.button>
          <% else %>
            <.button color="primary" type="submit" disabled="true" class="w-full">
              Generate Arena Code
            </.button>
          <% end %>

          <div class="flex justify-center my-12">
            <.link class="text-primary hover:underline" navigate={~p"/"}>&laquo; Back</.link>
          </div>
        </div>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(GameBox.PubSub, "games")
    end

    changeset =
      validate_arena(%{}, Changeset.cast({%{}, @arena_types}, %{}, Map.keys(@arena_types)))

    socket =
      socket
      |> assign(:player_id, session["player_id"])
      |> assign(:changeset, changeset)

    {:ok, socket}
  end

  @impl true
  def handle_params(
        %{"arena" => arena},
        _url,
        %{assigns: %{changeset: changeset}} = socket
      ) do
    changeset = %{"arena_id" => arena} |> validate_arena(changeset)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_params(_, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "join_arena",
        %{"arena_form" => %{"player_name" => player_name, "arena_id" => arena_id}},
        socket
      ) do
    %{assigns: %{player_id: player_id}} = socket

    arena_id = String.upcase(arena_id)
    player_name = String.upcase(player_name)

    case Arena.start(arena_id) do
      {:ok, :initiated} ->
        Arena.set_host(arena_id, player_id)

      {:ok, :joined} ->
        nil
    end

    :ok = Players.start(arena_id)

    case Players.register_player(arena_id, player_id, %{name: player_name, arena_id: arena_id}) do
      {:ok, _player} ->
        {:noreply, push_redirect(socket, to: ~p"/arena/#{arena_id}")}

      {:error, %Ecto.Changeset{}} ->
        {:noreply, put_flash(socket, :error, "Invalid data was received.")}

      {:error, msg} ->
        {:noreply, put_flash(socket, :error, msg)}
    end
  end

  def handle_event(
        "validate",
        %{"arena_form" => arena_params},
        %{assigns: %{changeset: changeset}} = socket
      ) do
    changeset = arena_params |> validate_arena(changeset) |> Map.put(:action, :validate)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_info({:games, games}, socket) do
    {:noreply, assign(socket, games: games)}
  end

  defp validate_arena(attrs, changeset) do
    {changeset, @arena_types}
    |> Changeset.cast(attrs, Map.keys(@arena_types))
    |> Changeset.validate_required([:player_name, :arena_id])
    |> Changeset.validate_length(:player_name, min: 2, max: 12)
    |> Changeset.validate_length(:arena_id,
      min: 4,
      max: 4,
      message: "Arena code should be exactly 4 characters"
    )
  end
end
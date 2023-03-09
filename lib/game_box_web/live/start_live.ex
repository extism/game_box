defmodule GameBoxWeb.StartLive do
  use GameBoxWeb, :live_view
  alias Ecto.Changeset
  alias GameBox.Arena
  alias GameBox.Players

  @arena_types %{
    player_name: :string,
    arena_id: :string
  }

  @charlist 'bcdfghjklmnpqrstvwxyz'

  @impl true
  def render(assigns) do
    ~H"""
    <.hero class="pt-0 md:pt-16 !mb-0" header="Start an arena" />
    <div class="w-full flex justify-center">
      <.simple_form
        :let={f}
        id="start_arena"
        for={@changeset}
        as="arena_form"
        class="w-full md:w-2/3 lg:w-1/2"
        phx-change="validate"
        phx-submit="start_arena"
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
        uri,
        %{assigns: %{changeset: changeset}} = socket
      ) do
    changeset = %{"arena_id" => arena} |> validate_arena(changeset)

    socket =
      socket
      |> assign(:changeset, changeset)
      |> assign(:uri, URI.parse(uri))

    {:noreply, socket}
  end

  def handle_params(_, uri, socket) do
    socket = assign(socket, :uri, URI.parse(uri))
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "start_arena",
        %{"arena_form" => %{"player_name" => player_name}},
        %{assigns: %{player_id: player_id}} = socket
      ) do
    arena_id = generate_uniq_arena()
    player_name = Players.format_name(player_name)

    with false <- is_nil(arena_id),
         false <- Arena.exists?(arena_id),
         {:ok, :initiated} <- Arena.start(arena_id),
         {:ok, _} <- Players.start(arena_id),
         {:ok, _player} <-
           Players.register_player(arena_id, player_id, %{name: player_name, arena_id: arena_id}) do
      Arena.set_host(arena_id, player_id)
      {:noreply, push_redirect(socket, to: ~p"/arena/#{arena_id}")}
    else
      _error ->
        {:noreply,
         put_flash(socket, :error, "Oops! We could't start an arena. Please try again.")}
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

  defp validate_arena(attrs, changeset) do
    {changeset, @arena_types}
    |> Changeset.cast(attrs, Map.keys(@arena_types))
    |> Changeset.validate_required([:player_name])
    |> Changeset.validate_length(:player_name, min: 2, max: 12)
  end

  defp generate_uniq_arena do
    generate = fn ->
      for _ <- 1..4,
          into: "",
          do: <<Enum.random(@charlist)>>
    end

    Enum.find_value(1..10, fn _x ->
      code = generate.()

      if not Arena.exists?(code) do
        code
      end
    end)
  end
end

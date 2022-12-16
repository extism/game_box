defmodule GameBox.Arena do
  @moduledoc false

  use GenServer

  require Logger

  alias GameBox.Arena
  alias GameBox.Games
  alias GameBox.Players
  alias Phoenix.PubSub

  @spec exists?(arena_id :: String.t()) :: boolean()
  def exists?(arena_id) do
    GameBox.ArenaRegistry
    |> Horde.Registry.lookup(arena_id)
    |> Enum.any?()
  end

  def load_game(arena_id, game_id) do
    GenServer.cast(via_tuple(arena_id), {:load_game, game_id})
  end

  def render_game(arena_id, assigns) do
    GenServer.call(via_tuple(arena_id), {:extism, "render", assigns})
  end

  def new_event(arena_id, event) do
    GenServer.call(via_tuple(arena_id), {:extism, "handle_event", event})
  end

  def state(arena_id) do
    if exists?(arena_id) do
      GenServer.call(via_tuple(arena_id), :state)
    else
      %{arena_id: arena_id}
    end
  end

  def via_tuple(arena_id) do
    {:via, Horde.Registry, {GameBox.ArenaRegistry, arena_id}}
  end

  def child_spec(opts) do
    arena_id = Keyword.fetch!(opts, :arena_id)

    %{
      id: "arena_#{arena_id}",
      start: {Arena, :start_link, [arena_id]},
      shutdown: 10_000,
      restart: :transient
    }
  end

  @doc """
  Start a Server with the specified arena_id as the name.
  """
  def start_link(arena_id) do
    case GenServer.start_link(Arena, %{arena_id: arena_id}, name: via_tuple(arena_id)) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Logger.info(
          "Already started Server #{inspect(arena_id)} at #{inspect(pid)}, returning :ignore"
        )

        :ignore
    end
  end

  @doc """
  Start a new game or join an existing game.
  """
  def start(arena_id) do
    case Horde.DynamicSupervisor.start_child(
           GameBox.DistributedSupervisor,
           {Arena, [arena_id: arena_id]}
         ) do
      {:ok, _pid} ->
        Logger.info("Started game server #{inspect(arena_id)}")

        :ok

      :ignore ->
        Logger.info("Game server #{inspect(arena_id)} already running. Joining")

        :ok
    end
  end

  @impl true
  def init(%{arena_id: arena_id}) do
    {:ok,
     %{
       arena_id: arena_id,
       ctx: Extism.Context.new(),
       plugin: nil,
       version: 0
     }}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:extism, "render", assigns}, _from, arena) do
    plugin = arena[:plugin]
    if plugin do
      {:ok, html} = Extism.Plugin.call(plugin, "render", Jason.encode!(assigns))
      {:reply, html, arena}
    else
      {:reply, "", arena}
    end
  end

  def handle_call({:extism, "handle_event", argument}, _from, arena) do
    %{plugin: plugin} = arena

    {:ok, response} = Extism.Plugin.call(plugin, "handle_event", Jason.encode!(argument))

    response = Jason.decode!(response, keys: :atoms)

    {:reply, response, arena, {:continue, :broadcast}}
  end

  @impl true
  def handle_continue(:broadcast, state) do
    %{arena_id: arena_id, version: version} = state
    PubSub.broadcast(GameBox.PubSub, "arena:#{arena_id}", {:version, version})
    {:noreply, state}
  end

  @impl true
  def handle_cast({:load_game, game_id}, state) do
    %{arena_id: arena_id, ctx: ctx, plugin: plugin} = state

    {:ok, game} = Games.get_game(game_id)

    :ok = Players.start_game(arena_id, game_id)

    unless is_nil(plugin) do
      Extism.Plugin.free(plugin)
    end

    path = "priv/static/#{game.path}"
    {:ok, plugin} = Extism.Context.new_plugin(ctx, %{wasm: [%{path: path}]}, false)

    player_ids =
      arena_id
      |> Players.list_players()
      |> Map.values()
      |> Enum.filter(& &1.game_id)
      |> Enum.map(&Map.get(&1, :name))

    {:ok, _output} =
      Extism.Plugin.call(plugin, "init_game", Jason.encode!(%{player_ids: player_ids}))

    PubSub.broadcast(GameBox.PubSub, "arena:#{arena_id}", :game_started)

    {:noreply, Map.put(state, :plugin, plugin)}
  end

  def broadcast_game_state(state) do
    %{arena_id: arena_id, version: version} = state
    PubSub.broadcast(GameBox.PubSub, "arena:#{arena_id}", {:version, version})
  end
end

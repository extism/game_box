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

  def get_constraints(arena_id, game_id) do
    GenServer.call(via_tuple(arena_id), {:extism, "get_constraints", game_id})
  end

  def load_game(arena_id, game_id) do
    GenServer.cast(via_tuple(arena_id), {:load_game, game_id})
  end

  def get_host(arena_id) do
    GenServer.call(via_tuple(arena_id), {:get_host, arena_id})
  end

  def set_host(arena_id, player_id) do
    GenServer.call(via_tuple(arena_id), {:set_host, player_id})
  end

  def get_game(arena_id) do
    GenServer.call(via_tuple(arena_id), {:get_game, arena_id})
  end

  def set_game(arena_id, game_id) do
    GenServer.call(via_tuple(arena_id), {:set_game, game_id})
  end

  def render_game(arena_id, assigns) do
    GenServer.call(via_tuple(arena_id), {:extism, "render", assigns})
  end

  def new_event(arena_id, event) do
    case GenServer.call(via_tuple(arena_id), {:extism, "handle_event", event}) do
      {:ok, r} -> {:ok, Jason.decode!(r, keys: :atoms)}
      err -> err
    end
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

        {:ok, :initiated}

      :ignore ->
        Logger.info("Game server #{inspect(arena_id)} already running. Joining")

        {:ok, :joined}
    end
  end

  @impl true
  def init(%{arena_id: arena_id}) do
    {:ok,
     %{
       arena_id: arena_id,
       ctx: Extism.Context.new(),
       plugin: nil,
       host_id: nil,
       game_id: nil
     }}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:extism, "get_constraints", game_id}, _from, arena) do
    {:ok, game} = Games.get_game(game_id)
    disk_volume_path = Application.get_env(:game_box, :disk_volume_path)
    wasm_path = Path.join([disk_volume_path, game.path])

    ctx = arena[:ctx]
    {:ok, plugin} = Extism.Context.new_plugin(ctx, %{wasm: [%{path: wasm_path}]}, false)

    if Extism.Plugin.has_function(plugin, "get_constraints") do
      {:ok, config} = Extism.Plugin.call(plugin, "get_constraints", nil)
      {:reply, Jason.decode!(config), arena}
    else
      default = %{
        min_players: 2,
        max_players: 2
      }

      {:reply, default, arena}
    end
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

    response = Extism.Plugin.call(plugin, "handle_event", Jason.encode!(argument))

    {:reply, response, arena}
  end

  # @impl true
  # def handle_continue(:broadcast, state) do
  #   %{arena_id: arena_id, version: version} = state
  #   PubSub.broadcast(GameBox.PubSub, "arena:#{arena_id}", {:version, version})
  #   {:noreply, state}
  # end

  @impl true
  def handle_call({:get_host, _arena_id}, _from, state) do
    {:reply, Map.fetch!(state, :host_id), state}
  end

  @impl true
  def handle_call({:set_host, player_id}, _from, state) do
    {:reply, {:ok, player_id}, Map.put(state, :host_id, player_id)}
  end

  @impl true
  def handle_call({:get_game, _arena_id}, _from, state) do
    {:reply, Map.fetch!(state, :game_id), state}
  end

  @impl true
  def handle_call({:set_game, game_id}, _from, state) do
    %{arena_id: arena_id} = state

    PubSub.broadcast(GameBox.PubSub, "arena:#{arena_id}", :game_selected)

    {:reply, {:ok, game_id}, Map.put(state, :game_id, game_id)}
  end

  @impl true
  def handle_cast({:load_game, game_id}, state) do
    %{arena_id: arena_id, ctx: ctx, plugin: plugin} = state

    {:ok, game} = Games.get_game(game_id)

    :ok = Players.start_game(arena_id, game_id)

    unless is_nil(plugin) do
      Extism.Plugin.free(plugin)
    end

    disk_volume_path = Application.get_env(:game_box, :disk_volume_path)
    path = Path.join([disk_volume_path, game.path])
    {:ok, plugin} = Extism.Context.new_plugin(ctx, %{wasm: [%{path: path}]}, false)

    player_ids =
      arena_id
      |> Players.list_players()
      |> Map.values()
      # just choose the first 2 users and the rest can watch
      |> Enum.take(2)
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

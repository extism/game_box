defmodule GameBox.Arena do
  @moduledoc false

  use GenServer

  require Logger

  alias GameBox.Arena
  alias GameBox.Games
  alias GameBox.Players
  alias Phoenix.PubSub

  @type arena_id :: String.t()
  @type game_id :: GameBox.Games.Game.t()

  @type state :: %{
    arena_id: arena_id,
    ctx: %Extism.Context{},
    plugin: nil
  }

  @spec exists?(arena_id :: String.t()) :: boolean()
  def exists?(arena_id) do
    GameBox.ArenaRegistry
    |> Horde.Registry.lookup(arena_id)
    |> Enum.any?()
  end

  def game_state(arena_id, player_id) do
    GenServer.call(via_tuple(arena_id), {:game_state, player_id})
  end

  @spec load_game(arena_id, game_id, player_id :: String.t()) :: :ok
  def load_game(arena_id, game_id, player_id) do
    GenServer.call(via_tuple(arena_id), {:load_game, game_id, player_id})
  end

  @spec render_game(arena_id(), game_state :: map) :: String.t() | nil
  def render_game(arena_id, game_state) do
    GenServer.call(via_tuple(arena_id), {:extism, "render", game_state})
  end

  def new_event(arena_id, event) do
    case GenServer.call(via_tuple(arena_id), {:extism, "handle_event", event}) do
      {:ok, result} ->
        {:ok, Jason.decode!(result, keys: :atoms)}

      {:error, message} ->
        {:error, message}
    end
  end

  @spec state(arena_id) :: state :: nil
  def state(arena_id) do
    if exists?(arena_id) do
      GenServer.call(via_tuple(arena_id), :state)
    end
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
       plugin: nil
     }}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:extism, "render", _game_state}, _from, %{plugin: nil} = state) do
    {:reply, nil, state}
  end

  def handle_call({:extism, "render", game_state}, _from, state) do
    %{plugin: plugin} = state
    params = Jason.encode!(game_state)
    {:ok, html} = Extism.Plugin.call(plugin, "render", params)
    {:reply, html, state}
  end

  def handle_call({:extism, "handle_event", argument}, _from, state) do
    %{plugin: plugin} = state
    params = Jason.encode!(argument)
    response = Extism.Plugin.call(plugin, "handle_event", params)
    {:reply, response, state, {:continue, :broadcast}}
  end

  def handle_call({:game_state, player_id}, _from, state) do
    %{plugin: plugin} = state
    if is_nil(plugin) do
      {:reply, nil, state}
    else
      {:ok, game_state} =
        Extism.Plugin.call(plugin, "game_state", player_id)
        |> IO.inspect(label: "GAME)STATE")

      {:reply, Jason.decode!(game_state), state}
    end
  end

  def handle_call({:load_game, game_id, player_id}, _from, state) do
    %{arena_id: arena_id, ctx: ctx, plugin: plugin} = state

    {:ok, game} = Games.get_game(game_id)

    :ok = Players.start_game(arena_id, game_id)

    unless is_nil(plugin) do
      Extism.Plugin.free(plugin)
    end

    disk_volume_path = Application.get_env(:game_box, :disk_volume_path)
    path = Path.join([disk_volume_path, game.path])
    {:ok, plugin} = Extism.Context.new_plugin(ctx, %{wasm: [%{path: path}]}, false)
    players = Players.list_players(arena_id)

    player_ids =
      players
      |> Map.values()
      |> Enum.filter(& &1.game_id)
      |> Enum.map(&Map.get(&1, :name))

    player_id = players[player_id][:name]

    {:ok, game_state} =
      Extism.Plugin.call(plugin, "init_game", Jason.encode!(%{player_id: player_id, player_ids: player_ids}))

    game_state = Jason.decode!(game_state)

    PubSub.broadcast(GameBox.PubSub, "arena:#{arena_id}", :game_started)

    {:reply, game_state, Map.put(state, :plugin, plugin)}
  end

  @impl true
  def handle_continue(:broadcast, state) do
    %{arena_id: arena_id} = state
    PubSub.broadcast(GameBox.PubSub, "arena:#{arena_id}", :game_update)
    {:noreply, state}
  end

  defp via_tuple(arena_id) do
    {:via, Horde.Registry, {GameBox.ArenaRegistry, arena_id}}
  end
end

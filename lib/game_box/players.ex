defmodule GameBox.Players do
  @moduledoc false

  use GenServer

  require Logger

  alias Ecto.Changeset
  alias GameBox.Players
  alias Phoenix.PubSub

  @fields %{
    id: %{type: :string, required: true},
    name: %{type: :string},
    game_id: %{type: :integer},
    pids: %{type: :array}
  }

  @schema Map.new(@fields, fn {key, %{type: type}} -> {key, type} end)

  @required @fields
            |> Enum.filter(fn {_key, opts} -> Map.get(opts, :required) end)
            |> Enum.map(fn {key, _} -> key end)

  @optional @fields
            |> Enum.reject(fn {_key, opts} -> Map.get(opts, :required) end)
            |> Enum.map(fn {key, _} -> key end)

  @all @required ++ @optional

  def get_player(arena_id, player_id) do
    GenServer.call(via_tuple(arena_id), {:get_player, player_id})
  end

  def list_players(arena_id) do
    GenServer.call(via_tuple(arena_id), :list_players)
  end

  def update_player(arena_id, player_id, params) do
    GenServer.call(via_tuple(arena_id), {:update_player, player_id, params})
  end

  def start_game(arena_id, game_id) do
    GenServer.cast(via_tuple(arena_id), {:start_game, game_id})
  end

  def end_game(arena_id, game_id) do
    GenServer.cast(via_tuple(arena_id), {:end_game, game_id})
  end

  def monitor(arena_id, player_id) do
    GenServer.cast(via_tuple(arena_id), {:monitor, player_id, self()})
  end

  @spec exists?(arena_id :: String.t()) :: boolean()
  def exists?(arena_id) do
    GameBox.ArenaRegistry
    |> Horde.Registry.lookup(arena_id)
    |> Enum.any?()
  end

  @impl true
  def handle_call({:get_player, player_id}, _from, %{players: players} = state) do
    {:reply, Map.fetch!(players, player_id), state}
  end

  def handle_call(:list_players, _from, %{players: players} = state) do
    online_players =
      players
      |> Enum.filter(fn {_player_id, player} -> Enum.any?(player.pids) end)
      |> Enum.into(%{})

    {:reply, online_players, state}
  end

  def handle_call({:update_player, player_id, params}, _from, %{players: players} = state) do
    player = Map.get(players, player_id, %{id: player_id, pids: []})

    case change_player(player, params) do
      {:ok, player} ->
        players = Map.put(players, player_id, player)
        state = Map.put(state, :players, players)
        {:reply, {:ok, player}, state, {:continue, :broadcast}}

      {:error, changeset} ->
        {:reply, {:error, changeset}, state}
    end
  end

  @impl true
  def handle_cast({:start_game, game_id}, %{players: players} = state) do
    players =
      Map.new(players, fn {id, player} ->
        {id, Map.put(player, :game_id, game_id)}
      end)

    state = Map.put(state, :players, players)

    {:noreply, state}
  end

  def handle_cast({:end_game, game_id}, %{players: players} = state) do
    players =
      Map.new(players, fn {id, player} ->
        player =
          if player.game_id == game_id do
            Map.put(player, :game_id, nil)
          else
            player
          end

        {id, player}
      end)

    state = Map.put(state, :players, players)

    {:noreply, state}
  end

  def handle_cast({:monitor, player_id, pid}, %{players: players} = state) do
    Process.monitor(pid)

    pids =
      players[player_id][:pids]
      |> Enum.concat([pid])
      |> Enum.uniq()

    players = put_in(players, [player_id, :pids], pids)
    state = Map.put(state, :players, players)

    {:noreply, state, {:continue, :broadcast}}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _}, %{players: players} = state) do
    player =
      players
      |> Map.values()
      |> Enum.find(&(pid in &1.pids))

    if is_nil(player) do
      {:noreply, state}
    else
      players = put_in(players, [player.id, :pids], List.delete(player.pids, pid))
      state = Map.put(state, :players, players)
      {:noreply, state, {:continue, :broadcast}}
    end
  end

  @impl true
  def handle_continue(:broadcast, %{arena_id: arena_id} = state) do
    PubSub.broadcast(GameBox.PubSub, "arena:#{arena_id}", :players_updated)

    {:noreply, state}
  end

  @impl true
  def init(arena_id) do
    {:ok, %{arena_id: arena_id, players: %{}}}
  end

  def child_spec(opts) do
    arena_id = Keyword.fetch!(opts, :arena_id)

    %{
      id: "players_#{arena_id}",
      start: {Players, :start_link, [arena_id]},
      shutdown: 10_000,
      restart: :transient
    }
  end

  def start_link(arena_id) do
    case GenServer.start_link(Players, arena_id, name: via_tuple(arena_id)) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Logger.info(
          "Already started Player #{inspect(arena_id)} at #{inspect(pid)}, returning :ignore"
        )

        :ignore
    end
  end

  @doc """
  Start a new player.
  """
  def start(arena_id) do
    case Horde.DynamicSupervisor.start_child(
           GameBox.DistributedSupervisor,
           {Players, [arena_id: arena_id]}
         ) do
      {:ok, _pid} ->
        Logger.info("Started players server #{inspect(arena_id)}")

        :ok

      :ignore ->
        Logger.info("Players server #{inspect(arena_id)} already running. Joining")

        :ok
    end
  end

  @doc """
  Return the `:via` tuple for referencing and interacting with a specific Server.
  """
  def via_tuple(arena_id), do: {:via, Horde.Registry, {GameBox.PlayersRegistry, arena_id}}

  defp change_player(player, params) do
    {player, @schema}
    |> Changeset.cast(params, @all)
    |> Changeset.validate_required(@required)
    |> Changeset.apply_action(:update)
  end
end

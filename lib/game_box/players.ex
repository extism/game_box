defmodule GameBox.Players do
  @moduledoc false

  use GenServer

  require Logger

  alias Ecto.Changeset
  alias GameBox.Arena
  alias GameBox.Players

  @fields %{
    id: %{type: :string, required: true},
    name: %{type: :string},
    game_id: %{type: :integer},
    pids: %{type: :array},
    joined_at: %{type: :integer, required: true}
  }

  @schema Map.new(@fields, fn {key, %{type: type}} -> {key, type} end)

  @required @fields
            |> Enum.filter(fn {_key, opts} -> Map.get(opts, :required) end)
            |> Enum.map(fn {key, _} -> key end)

  @optional @fields
            |> Enum.reject(fn {_key, opts} -> Map.get(opts, :required) end)
            |> Enum.map(fn {key, _} -> key end)

  @all @required ++ @optional

  @spec format_name(player_name :: String.t()) :: String.t()
  def format_name(player_name) do
    String.upcase(player_name)
  end

  def get_player(arena_id, player_id) do
    GenServer.call(via_tuple(arena_id), {:get_player, player_id})
  end

  def list_players(arena_id) do
    GenServer.call(via_tuple(arena_id), :list_players)
  end

  def update_player(arena_id, player_id, params) do
    GenServer.call(via_tuple(arena_id), {:update_player, player_id, params})
  end

  def register_player(arena_id, player_id, params) do
    GenServer.call(via_tuple(arena_id), {:register_player, player_id, params})
  end

  def start_game(arena_id, game_id) do
    GenServer.cast(via_tuple(arena_id), {:start_game, game_id})
  end

  def end_game(arena_id) do
    GenServer.cast(via_tuple(arena_id), :end_game)
  end

  def monitor(arena_id, player_id) do
    GenServer.cast(via_tuple(arena_id), {:monitor, player_id, self()})
  end

  @spec exists?(arena_id :: String.t()) :: boolean()
  def exists?(arena_id) do
    arena_id = Arena.normalize_id(arena_id)

    GameBox.ArenaRegistry
    |> Horde.Registry.lookup(arena_id)
    |> Enum.any?()
  end

  @impl true
  def handle_call({:get_player, player_id}, _from, state) do
    player =
      case Map.fetch(state, player_id) do
        {:ok, player} -> player
        :error -> nil
      end

    {:reply, player, state}
  end

  def handle_call(:list_players, _from, players) do
    online_players =
      players
      |> Enum.filter(fn {_player_id, player} -> Enum.any?(player.pids) end)
      |> Enum.into(%{})

    {:reply, online_players, players}
  end

  def handle_call(
        {:register_player, player_id, %{arena_id: _arena_id, name: name} = params},
        _from,
        state
      ) do
    player = Map.get(state, player_id, nil)

    name_taken =
      state
      |> Map.values()
      |> Enum.any?(&(&1.name == name && &1.id != player_id))

    update = fn player, params ->
      case change_player(player, params) do
        {:ok, player} ->
          {:reply, {:ok, player}, Map.put(state, player.id, player), {:continue, :broadcast}}

        {:error, changeset} ->
          {:reply, {:error, changeset}, state}
      end
    end

    cond do
      is_nil(player) and not name_taken ->
        joined_at = DateTime.utc_now() |> DateTime.to_unix()
        update.(%{id: player_id, pids: []}, Map.put(params, :joined_at, joined_at))

      name_taken ->
        {:reply, {:error, "Player name already taken"}, state}

      true ->
        update.(player, params)
    end
  end

  def handle_call({:update_player, player_id, params}, _from, state) do
    player = Map.get(state, player_id, %{id: player_id, pids: []})

    case change_player(player, params) do
      {:ok, player} ->
        {:reply, {:ok, player}, Map.put(state, player_id, player), {:continue, :broadcast}}

      {:error, changeset} ->
        {:reply, {:error, changeset}, state}
    end
  end

  @impl true
  def handle_cast({:start_game, game_id}, players) do
    players =
      Map.new(players, fn {id, player} ->
        {id, Map.put(player, :game_id, game_id)}
      end)

    {:noreply, players}
  end

  def handle_cast(:end_game, players) do
    players =
      Map.new(players, fn {id, player} ->
        {id, Map.put(player, :game_id, nil)}
      end)

    {:noreply, players}
  end

  def handle_cast({:monitor, player_id, pid}, players) do
    Process.monitor(pid)

    pids =
      players[player_id][:pids]
      |> Enum.concat([pid])
      |> Enum.uniq()

    {:noreply, put_in(players, [player_id, :pids], pids), {:continue, :broadcast}}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _}, players) do
    player =
      players
      |> Map.values()
      |> Enum.find(&(pid in &1.pids))

    if is_nil(player) do
      {:noreply, players}
    else
      players = put_in(players, [player.id, :pids], List.delete(player.pids, pid))

      players
      |> Map.values()
      |> Enum.flat_map(&Map.get(&1, :pids))
      |> Enum.empty?()
      |> case do
        true ->
          # In the case that the pids are empty, we fire off a send_after
          # to ensure that no players have required the view before
          # gracefully shutting it down.
          timeout = Application.get_env(:game_box, :tear_down_timeout)
          Process.send_after(self(), :check_if_pids_still_empty, timeout)
          {:noreply, players}

        _ ->
          {:noreply, players, {:continue, :broadcast}}
      end
    end
  end

  def handle_info(:check_if_pids_still_empty, players) do
    players
    |> Map.values()
    |> Enum.flat_map(&Map.get(&1, :pids))
    |> Enum.empty?()
    |> case do
      true ->
        {:stop, :normal, players}

      _ ->
        {:noreply, players}
    end
  end

  @impl true
  def handle_continue(:broadcast, players) do
    players
    |> Map.values()
    |> Enum.flat_map(&Map.get(&1, :pids))
    |> Enum.each(&send(&1, :players_updated))

    {:noreply, players}
  end

  @impl true
  def init(_) do
    {:ok, %{}}
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
    case GenServer.start_link(Players, [], name: via_tuple(arena_id)) do
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
    arena_id = Arena.normalize_id(arena_id)

    case Horde.DynamicSupervisor.start_child(
           GameBox.DistributedSupervisor,
           {Players, [arena_id: arena_id]}
         ) do
      {:ok, _pid} ->
        Logger.info("Started players server #{inspect(arena_id)}")

        {:ok, :started}

      :ignore ->
        Logger.info("Players server #{inspect(arena_id)} already running. Joining")

        {:ok, :joined}

      _ ->
        {:error}
    end
  end

  @impl true
  def terminate(:normal, state), do: state

  @doc """
  Return the `:via` tuple for referencing and interacting with a specific Server.
  """
  def via_tuple(arena_id) do
    arena_id = Arena.normalize_id(arena_id)

    {:via, Horde.Registry, {GameBox.PlayersRegistry, arena_id}}
  end

  defp change_player(player, params) do
    {player, @schema}
    |> Changeset.cast(params, @all)
    |> Changeset.validate_required(@required)
    |> Changeset.apply_action(:update)
  end
end

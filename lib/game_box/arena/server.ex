defmodule GameBox.Arena.Server do
  @moduledoc false

  use GenServer

  require Logger

  alias GameBox.Arena.Player
  alias GameBox.Arena.State
  alias GameBox.Arena.Server
  alias Phoenix.PubSub

  def child_spec(opts) do
    player = Keyword.fetch!(opts, :player)
    code = Keyword.fetch!(opts, :code)

    %{
      id: "arena_#{code}",
      start: {Server, :start_link, [code, player]},
      shutdown: 10_000,
      restart: :transient
    }
  end

  @doc """
  Start a Server with the specified code as the name.
  """
  def start_link(code, %Player{} = player) do
    case GenServer.start_link(Server, %{player: player, code: code}, name: via_tuple(code)) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Logger.info(
          "Already started Server #{inspect(code)} at #{inspect(pid)}, returning :ignore"
        )

        :ignore
    end
  end

  def game_state(code) do
    GenServer.call(via_tuple(code), :game_state)
  end

  @doc """
  Start a new game or join an existing game.
  """
  @spec start_or_join(State.code(), Player.t()) ::
          {:ok, :started | :joined} | {:error, String.t()}
  def start_or_join(code, %Player{} = player) do
    case Horde.DynamicSupervisor.start_child(
           GameBox.DistributedSupervisor,
           {Server, [code: code, player: player]}
         ) do
      {:ok, _pid} ->
        Logger.info("Started game server #{inspect(code)}")
        {:ok, :started}

      :ignore ->
        Logger.info("Game server #{inspect(code)} already running. Joining")

        join_arena(code, player)
        {:ok, :joined}
    end
  end

  def leave_arena(code, player) do
    GenServer.cast(via_tuple(code), {:leave_arena, player})
  end

  @doc """
  Join a running arena server
  """
  @spec join_arena(State.code(), Player.t()) :: :ok | {:error, String.t()}
  def join_arena(code, %Player{} = player) do
    GenServer.cast(via_tuple(code), {:join_arena, player})
  end

  @impl true
  def init(%{player: player, code: code}) do
    # Create the new game state with the creating player assigned
    {:ok, State.new(code, player)}
  end

  @doc """
  Return the `:via` tuple for referencing and interacting with a specific Server.
  """
  def via_tuple(code), do: {:via, Horde.Registry, {GameBox.ArenaRegistry, code}}

  @doc """
  Lookup the Server and report if it is found. Returns a boolean.
  """
  @spec server_found?(State.code()) :: boolean()
  def server_found?(code) do
    # Look up the game in the registry. Return if a match is found.
    case Horde.Registry.lookup(GameBox.ArenaRegistry, code) do
      [] -> false
      [{pid, _} | _] when is_pid(pid) -> true
    end
  end

  @impl true
  def handle_call(:game_state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:leave_arena, player}, state) do
    state = State.leave_player(state, player)
    broadcast_game_state(state)

    if state.players == [] do
      {:stop, :normal, state}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:join_arena, %Player{} = player}, %State{} = state) do
    state = State.join_player(state, player)
    broadcast_game_state(state)
    {:noreply, state}
  end

  def broadcast_game_state(%State{} = state) do
    PubSub.broadcast(GameBox.PubSub, "arena:#{state.code}", {:arena_state, state})
  end
end

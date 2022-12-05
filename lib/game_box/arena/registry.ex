defmodule GameBox.Arena.Registry do
  use GenServer

  def start_link(_init_arg) do
    GenServer.start_link(__MODULE__, nil, name: :arena_registry)
  end

  def whereis_name(code) do
    GenServer.call(:arena_registry, {:whereis_name, code})
  end

  def register_name(code, pid) do
    GenServer.call(:arena_registry, {:register_name, code, pid})
  end

  def unregister_name(code) do
    GenServer.cast(:arena_registry, {:unregister_name, code})
  end

  def send(code, message) do
    case whereis_name(code) do
      :undefined ->
        {:badarg, {code, message}}

      pid ->
        Kernel.send(pid, message)
        pid
    end
  end

  # Callbacks

  def init(_) do
    {:ok, Map.new}
  end

  def handle_call({:whereis_name, code}, _from, state) do
    {:reply, Map.get(state, code, :undefined), state}
  end

  def handle_cast({:unregister_name, code}, state) do
    {:noreply, Map.delete(state, code)}
  end

  def handle_call({:register_name, code, pid}, _from, state) do
    case Map.get(state, code) do
      nil ->
        # When a new process is registered, we start monitoring it
        Process.monitor(pid)
        {:reply, :yes, Map.put(state, code, pid)}
      _ ->
        {:reply, :no, state}
    end
  end

  def handle_info({:DOWN, _, :process, pid, _}, state) do
    {:noreply, remove_pid(state, pid)}
  end

  def remove_pid(state, pid_to_remove) do
    remove = fn {_key, pid} -> pid  != pid_to_remove end
    Enum.filter(state, remove) |> Enum.into(%{})
  end
end

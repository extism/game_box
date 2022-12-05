defmodule GameBox.Arena.Supervisor do
  use DynamicSupervisor

  def start_link(_init_arg) do
    DynamicSupervisor.start_link(__MODULE__, [], name: :arena_supervisor)
  end

  def start_arena(code) do
    spec = %{id: GameBox.Arena.Server, start: {GameBox.Arena.Server, :start_link, [code]} , type: :worker}
    DynamicSupervisor.start_child(:arena_supervisor, spec)
  end

  def init(init_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [init_arg]
    )
  end
end

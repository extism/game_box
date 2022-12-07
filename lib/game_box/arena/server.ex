defmodule GameBox.Arena.Server do
  use GenServer

  def start_link(code) do
    GenServer.start_link(__MODULE__, [], name: via_tuple(code))
  end

  defp via_tuple(code) do
    {:via, GameBox.Arena.Registry, {:arena, code}}
  end

  # API

  def load(code, manifest, wasi) do
    GenServer.call(via_tuple(code), {:new, manifest, wasi})
  end

  def exec(code, call_details) do
    GenServer.call(via_tuple(code), call_details)
  end

  def exists?(code) do
    code
    |> via_tuple()
    |> GenServer.whereis()
    |> is_pid()
  end

  # Callabcks

  @impl true
  def init(_init_arg) do
    ctx = Extism.Context.new()
    # as our state we will store a {Context, Plugin} tuple
    {:ok, {ctx, nil}}
  end

  # This special call is for loading or reloading a plugin given a manifest
  @impl true
  def handle_call({:new, manifest, wasi}, _from, {ctx, plugin}) do
    # if we have an exiting Plugin let's free it
    if plugin do
        Extism.Plugin.free(plugin)
    end
    # Load a new plugin given the manifest and store it in the new state
    {:ok, plugin}  = Extism.Context.new_plugin(ctx, manifest, wasi)
    {:reply, {:ok, plugin}, {ctx, plugin}}
  end

  # this is a generic way to call functions on the Extism.Plugin module
  # we're mostly going to use `call` here:
  #     e.g. call_details = {:call, "count_vowels", "this is a test"]}
  @impl true
  def handle_call(call_details, _from, {ctx, plugin}) do
    [func_name | args] = Tuple.to_list(call_details)
    response = apply(Extism.Plugin, func_name, [plugin | args])
    {:reply, response, {ctx, plugin}}
  end
end

defmodule GameBox do

  @doc """
  Starts an arena and returns the arena code (4 char alpha code).
  This function starts a Arena GenServer and registers the pid to the arena code.

  ## Parameters

    - host_player_id: String representing the host player (player that controls the arena)

  ## Returns

    The 4 char Arena Code
  """
  def start_arena(_host_player_id) do
    code = generate_code()
    {:ok, _pid} = GameBox.Arena.Server.start_link(code)
    {:ok, _plugin} = load_game(code, "/Users/ben/d/game_box/games/tictactoe/target/wasm32-unknown-unknown/debug/tictactoe_rs.wasm")
    {:ok, _plugin} = init_game(code, ["benjamin", "brian"])
    code
  end

  @doc """
  Loads a game plugin into the arena at the given code.

  ## Parameters

    - code: The 4 char Arena code
    - path: A path to the wasm file containing the game
  """
  def load_game(code, path) do
    GameBox.Arena.Server.load(code, %{ wasm: [ %{ path: path } ]}, false)
  end

  @doc """
  Initializes the game memory. You shouldn't make any calls to the game before doing this.
  I'll likely combine this with load_game at some point

  ## Parameters

    - code: The 4 char Arena code
    - player_ids: A list of strings of the player ids in the game
  """
  def init_game(code, player_ids) do
    GameBox.Arena.Server.plugin_apply(code, {:call, "init_game", JSON.encode!(%{player_ids: player_ids})})
  end

  @doc """
  Renders the game given the assigns from the socket.

  ## Parameters

    - code: The 4 char Arena code
    - assigns: An unstructured map of template variables that came from the user socket
  """
  def render_game(code, assigns) do
    GameBox.Arena.Server.plugin_apply(code, {:call, "render", JSON.encode!(assigns)})
  end

  @doc """
  Calls the event handler callback in the game with the event details from live view
  Returns a map representing new socket assignments to attach to the user socket

  ## Parameters

    - code: The 4 char Arena code
    - assigns: An unstructured map of event details from live view

  """
  def handle_game_event(code, event) do
    Jason.decode!(
      GameBox.Arena.Server.plugin_apply(code, {:call, "handle_event", JSON.encode!(event)}),
      keys: :atoms
    )
  end

  def fetch(code) do
    GameBox.Arena.Registry.whereis_name(code)
  end

  defp generate_code do
    code = for _ <- 1..4, into: "", do: <<Enum.random('ABCDEFGHIJKLMNOPQRSTUVWXYZ')>>

    if GameBox.Arena.Server.exists?(code) do
      generate_code()
    else
      code
    end
  end
end

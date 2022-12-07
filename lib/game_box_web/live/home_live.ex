defmodule GameBoxWeb.HomeLive do
  use GameBoxWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1>Game Box</h1>

    <h2>Create a Game</h2>
    <form id="create_game" phx-submit="create_game">
      <input type="text" name="player_id" />
      <button>Submit</button>
    </form>

    <h2>Join a Game</h2>
    <form id="join_game" phx-submit="join_game">
      <input type="text" name="player_id" />
      <input type="text" name="code" />
      <button>Submit</button>
    </form>
    """
  end

  def handle_event("create_game", unsigned_params, socket) do
    %{"player_id" => player_id} = unsigned_params
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, GameBoxWeb.ArenaLive, %{player_id: player_id}))}
  end

  def handle_event("join_game", unsigned_params, socket) do
    %{"code" => code, "player_id" => _player_id} = unsigned_params

    if GameBox.Arena.Server.exists?(code) do
      {:noreply, push_redirect(socket, to: Routes.live_path(socket, GameBoxWeb.ArenaLive, %{code: code}))}
    else
      {:noreply, put_flash(socket, :error, "#{code} is not a valid game code.")}
    end
  end
end

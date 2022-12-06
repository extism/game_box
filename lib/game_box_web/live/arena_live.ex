defmodule GameBoxWeb.ArenaLive do
  use Phoenix.LiveView

  def render(assigns) do
    input = JSON.encode!(%{
      player_id: assigns[:player_id],
      code: assigns[:code],
    })
    {:ok, content} = GameBox.Arena.Server.call(assigns[:code], {:call, "render", input})
    ~H"<%= Phoenix.HTML.raw content %>"
  end

  def mount(%{ "code" => code } = _params, session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(GameBox.PubSub, "arena:" <> code)
    end
    # TODO: assign a unique session to the player. the player should have a unique name
    # as well that they enter on the lobby join room
    new_player_id = :crypto.strong_rand_bytes(16) |> Base.encode64 |> binary_part(0, 16)
    {:ok, assign(socket, version: "0", code: code, player_id: socket.assigns[:player_id] || new_player_id)}
  end
  def mount(params, session, socket) do
    {:ok, socket}
  end

  def handle_event(event_name, value, socket) do
    code = socket.assigns[:code]

    input = JSON.encode!(%{
       "code" => code,
       "event_name" => event_name,
       "player_id" => socket.assigns[:player_id],
       "value" => value,
    })
    {:ok, version} = GameBox.Arena.Server.call(code, {:call, "handle_event", input})
    broadcast_change(code, version)
    {:noreply, assign(socket, :version, version)}
  end

  def handle_info({version}, socket) do
    {:noreply, assign(socket, :version, version)}
  end

  defp broadcast_change(code, version) do
    Phoenix.PubSub.broadcast(GameBox.PubSub, "arena:" <> code, {version})
  end
end

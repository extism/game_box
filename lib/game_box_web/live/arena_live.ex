defmodule GameBoxWeb.ArenaLive do
  use Phoenix.LiveView

  def render(assigns) do
    IO.puts("render Assigns: ")
    IO.inspect(assigns)
    input = JSON.encode!(
      player_id: assigns["player_id"],
      code: assigns["code"]
    )
    IO.inspect(input)
    {:ok, content} = GameBox.Arena.Server.call(assigns["code"], {:call, "render", input})
    ~H"""
    <div>
      <p class="alert alert-danger" role="alert"><%= live_flash(@flash, :error) %></p>
      <%= Phoenix.HTML.raw content %>
    </div>
    """
  end

  def mount(params, _session, socket) do
    %{"player_id" => player_id} = params

    code = GameBox.Arena.start_arena()

    if connected?(socket) do
      Phoenix.PubSub.subscribe(GameBox.PubSub, "arena:" <> code)
    end

    {:ok, assign(socket, version: "0", code: code, player_id: player_id)}
  end

  def handle_event(event_name, value, socket) do
    code = socket.assigns["code"]

    input = JSON.encode!(%{
       "code" => code,
       "player_id" => socket.assigns["player_id"],
       "event_name" => event_name,
       "value" => value,
    })

    case GameBox.Arena.Server.call(code, {:call, "handle_event", input}) do
      {:ok, new_assigns} ->
        new_assigns = JSON.decode!(new_assigns)
        error = Map.get(new_assigns, "error")
        if error do
          broadcast_change(code, new_assigns["version"])
          {:noreply, socket |> assign(new_assigns) |> put_flash(:error, error)}
        else
          broadcast_change(code, new_assigns["version"])
          {:noreply, assign(socket, new_assigns)}
        end
      {:error, err} ->
        IO.puts("Call failed: ")
        IO.puts(input)
        IO.puts(err)
        {:noreply, put_flash(socket, :error, err)}
    end
  end

  def handle_info({version}, socket) do
    {:noreply, assign(socket, "version", version)}
  end

  defp broadcast_change(code, version) do
    Phoenix.PubSub.broadcast(GameBox.PubSub, "arena:" <> code, {version})
  end
end

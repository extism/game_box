defmodule GameBoxWeb.ArenaLive do
  use Phoenix.LiveView

  def render(assigns) do
    IO.puts("render Assigns: ")
    input_assigns = %{
      player_id: assigns[:player_id],
      code: assigns[:code]
    }
    case GameBox.render_game(assigns[:code], input_assigns) do
      {:ok, content} ->
        ~H"""
        <div>
          <p class="alert alert-danger" role="alert"><%= live_flash(@flash, :error) %></p>
          <%= Phoenix.HTML.raw content %>
        </div>
        """
      {:error, err} ->
        IO.puts(err)
        ~H""
    end
  end

  def mount(%{"player_id" => player_id} = _params, _session, socket) do
    code = GameBox.start_arena(player_id)
    IO.puts("Starting game " <> code)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(GameBox.PubSub, "arena:" <> code)
    end

    {:ok, assign(socket, version: 0, code: code, player_id: player_id)}
  end

  def handle_event(event_name, value, socket) do
    code = socket.assigns["code"]

    event = %{
       "code" => code,
       "player_id" => socket.assigns["player_id"],
       "event_name" => event_name,
       "value" => value,
    }

    case GameBox.handle_game_event(code, event) do
      {:ok, new_assigns} ->
        new_assigns = Jason.decode!(new_assigns, keys: :atoms)
        error = Map.get(new_assigns, :error)
        if error do
          broadcast_change(code, new_assigns[:version])
          {:noreply, socket |> assign(new_assigns) |> put_flash(:error, error)}
        else
          broadcast_change(code, new_assigns[:version])
          {:noreply, assign(socket, new_assigns)}
        end
      {:error, err} ->
        IO.puts("Call failed: ")
        IO.puts(event)
        IO.puts(err)
        {:noreply, put_flash(socket, :error, err)}
    end
  end

  def handle_info({version}, socket) do
    {:noreply, assign(socket, :version, version)}
  end

  defp broadcast_change(code, version) do
    Phoenix.PubSub.broadcast(GameBox.PubSub, "arena:" <> code, {version})
  end
end

defmodule GameBoxWeb.ArenaLive do
  use Phoenix.LiveView

  def render(assigns) do
    IO.puts "Render"
    IO.inspect assigns
    board = assigns[:board]
    #{:ok, board} = GameBox.Arena.Server.call(code, {:call, "render", ""})

    ~H"<%= Phoenix.HTML.raw board %>"
  end

  def mount(%{ "code" => code } = _params, _session, socket) do
    IO.puts "Code: "
    {:ok, board} = GameBox.Arena.Server.call(code, {:call, "render", ""})
    {:ok, assign(socket, board: board, code: code)}
  end

  def mount(params, session, socket) do
    # IO.inspect params
    # IO.inspect session
    # IO.inspect socket

    {:ok, socket}
  end

  def handle_event(event_name, value, socket) do
    code = socket.assigns[:code]
    input = JSON.encode!(%{
       "code" => code,
       "event_name" => event_name,
       "player_id" => "player1",
       "value" => value,
    })
    IO.puts "Handle Event"
    IO.inspect(input)
    result = GameBox.Arena.Server.call(code, {:call, "handle_event", input})
    IO.inspect(result)
    {:ok, board} = GameBox.Arena.Server.call(code, {:call, "render", ""})
    {:noreply, assign(socket, :board, board)}
  end

  # def mount(_params, %{"current_user_id" => user_id}, socket) do
  #   if connected?(socket), do: Process.send_after(self(), :update, 30000)

  #   # case Thermostat.get_user_reading(user_id) do
  #   #   {:ok, temperature} ->
  #   #     {:ok, assign(socket, temperature: temperature, user_id: user_id)}

  #   #   {:error, _reason} ->
  #   #     {:ok, redirect(socket, to: "/error")}
  #   # end
  # end

  # def handle_info(:update, socket) do
  #   Process.send_after(self(), :update, 30000)
  #   {:ok, temperature} = Thermostat.get_reading(socket.assigns.user_id)
  #   {:noreply, assign(socket, :temperature, temperature)}
  # end
end

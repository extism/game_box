defmodule GameBoxWeb.WelcomeLive do
  use GameBoxWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>Welcome to GameBox</div>
    """
  end
end

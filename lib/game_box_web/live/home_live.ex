defmodule GameBoxWeb.HomeLive do
  use GameBoxWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.h2>Homepage</.h2>
    </div>
    """
  end
end

defmodule GameBoxWeb.Divider do
  @moduledoc """
  Light gray divider used for breaking up content.
  """

  use Phoenix.Component

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def divider(assigns) do
    ~H"""
    <div class="border-b border-1 border-zinc-600 mb-5"></div>
    """
  end
end

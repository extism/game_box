defmodule GameBoxWeb.HomeLive do
  use GameBoxWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1>Game Box</h1>
    <%= if @username == :unset do %>
      <form id="username_form" method="get">
        <input type="text" name="username" />
        <button>Submit</button>
      </form>
    <% else %>
      <p>Current User: <%= @username %></p>
    <% end %>
    """
  end
end

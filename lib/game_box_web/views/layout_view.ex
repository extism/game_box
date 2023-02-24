defmodule GameBoxWeb.LayoutView do
  use GameBoxWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  attr :suffix, :string, default: nil

  def navigation(assigns) do
    ~H"""
    <li>
      <.link href={~p"/"} class="hover:!text-primary">
        Home
      </.link>
    </li>
    <%= if assigns[:current_user] do %>
      <li>
        <.link href={~p"/upload"} class="hover:!text-primary">
          Upload Game
        </.link>
      </li>
      <li>
        <.link href={~p"/auth/delete"} class="hover:!text-primary">Sign Out</.link>
      </li>
    <% else %>
      <li>
        <.link href={~p"/auth/github"} class="hover:!text-primary">
          Sign in with Github
        </.link>
      </li>
    <% end %>
    """
  end
end

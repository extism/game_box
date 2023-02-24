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
    <ul class="grow flex justify-end items-center font-display text-xs">
      <li class="mr-12">
        <.link href={~p"/"}>
          Home
        </.link>
      </li>
      <%= if assigns[:current_user] do %>
        <li class="mr-12">
          <.link href={~p"/upload"}>
            Upload Game
          </.link>
        </li>
        <li>
          <.link href={~p"/auth/delete"}>Sign Out</.link>
        </li>
      <% else %>
        <li>
          <.link href={~p"/auth/github"}>
            Sign in with Github
          </.link>
        </li>
      <% end %>
    </ul>
    """
  end
end

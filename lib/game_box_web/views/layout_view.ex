defmodule GameBoxWeb.LayoutView do
  use GameBoxWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  attr :suffix, :string, default: nil

  def navigation(assigns) do
    ~H"""
    <li>
      <.link href={~p"/"} class="hover:!text-primary">
        Join/Start Arena
      </.link>
    </li>
    <li>
      <.link href={~p"/about"} class="hover:!text-primary">
        About
      </.link>
    </li>
    <li>
      <.link href={~p"/upload"} class="hover:!text-primary">
        Upload Game
      </.link>
    </li>
    """
  end

  def check_data_confirm(assigns) do
    if !is_nil(assigns[:uri]) && Map.get(assigns[:uri], :path) == "/start" do
      true
    end
  end
end

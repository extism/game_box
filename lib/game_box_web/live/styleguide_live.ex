defmodule GameBoxWeb.StyleguideLive do
  use GameBoxWeb, :live_view
  # import Phoenix.Component, only: [embed_templates: 1]
  use GameBoxWeb, :component

  embed_templates "styleguide/*"

  def render(assigns) do
    ~H"""
    <.h1>Styleguide</.h1>
    """
  end
end

defmodule GameBoxWeb.StyleguideLive do
  use GameBoxWeb, :live_view
  # import Phoenix.Component, only: [embed_templates: 1]
  use GameBoxWeb, :component

  embed_templates "styleguide/*"

  embed_templates "styleguide/*"

  def render(assigns) do
    ~H"""
    <.h2>Styleguide</.h2>
    <.tabs>
      <.tab patch={Routes.styleguide_path(@socket, :styleguide)} label="Styleguide Home" />
      <.tab patch={Routes.styleguide_path(@socket, :typography)} replace={true} label="Typography" />
    </.tabs>
    <div class="mx-3">
      <%= case @live_action do %>
        <% :styleguide -> %>
          <.p>
            This styleguide should be referenced as the single source of truth for implementation of all elements and components. As such, this styleguide should be updated as the design system evolves. Whenever new components are created, they should also be added here.
          </.p>
        <% :typography -> %>
          <.typography />
      <% end %>
    </div>
    """
  end
end

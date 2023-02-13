defmodule GameBoxWeb.StyleguideLive do
  import Phoenix.Component, only: [embed_templates: 1]
  use GameBoxWeb, :live_view
  # import Phoenix.Component, only: [embed_templates: 1]
  use GameBoxWeb, :component

  embed_templates "styleguide/*"

  embed_templates "styleguide/*"

  def render(assigns) do
    ~H"""
    <.h1>Styleguide</.h1>
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

  def handle_params(params, url, socket) do
    IO.inspect(params, label: "HEY GIRL THESE ARE YOUR PARAMS")
    IO.inspect(url, label: "HEY GIRL THIS IS YOUR URL")
    IO.inspect(socket, label: "HEY GIRL THIS YOUR SOCKET")
    {:noreply, socket}
  end
end

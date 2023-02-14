defmodule GameBoxWeb.StyleguideLive do
  use GameBoxWeb, :live_view
  # import Phoenix.Component, only: [embed_templates: 1]
  use GameBoxWeb, :component

  embed_templates "styleguide/*"

  embed_templates "styleguide/*"

  # def mount(_params, _session, socket) do
  #   socket = assign(socket, is_active: false)
  #   {:ok, socket}
  # end

  def render(assigns) do
    ~H"""
    <.h2>Styleguide</.h2>
    <.tabs :let={is_active} class="my-10">
      <.tab
        patch={Routes.styleguide_path(@socket, :styleguide)}
        replace={true}
        label="Styleguide Home"
        is_active={is_active?(@live_action, :styleguide)}
      />
      <.tab
        patch={Routes.styleguide_path(@socket, :colors)}
        replace={true}
        label="Colors"
        is_active={is_active?(@live_action, :colors)}
      />
      <.tab
        patch={Routes.styleguide_path(@socket, :typography)}
        replace={true}
        label="Typography"
        is_active={is_active?(@live_action, :typography)}
      />
    </.tabs>
    <div class="mx-3">
      <%= case @live_action do %>
        <% :styleguide -> %>
          <.p>
            This styleguide should be referenced as the single source of truth for implementation of all elements and components. As such, this styleguide should be updated as the design system evolves. Whenever new components are created, they should also be added here.
          </.p>
        <% :typography -> %>
          <.typography />
        <% :colors -> %>
          <.colors />
      <% end %>
    </div>
    """
  end

  def handle_params(params, _url, socket) do
    {:noreply, socket}
  end

  defp is_active?(live_action, current) do
    if live_action == current do
      true
    end
  end
end

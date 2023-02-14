defmodule GameBoxWeb.StyleguideLive do
  use GameBoxWeb, :live_view
  # import Phoenix.Component, only: [embed_templates: 1]
  import GameBoxWeb.ColorSwatch

  embed_templates "styleguide/*"

  # def mount(_params, _session, socket) do
  #   socket = assign(socket, is_active: false)
  #   {:ok, socket}
  # end

  def render(assigns) do
    ~H"""
    <.h2>Styleguide</.h2>
    <.tabs class="my-10">
      <.tab
        patch={Routes.styleguide_path(@socket, :styleguide)}
        replace={true}
        label="Colors"
        is_active={is_active?(@live_action, :styleguide)}
      />
      <.tab
        patch={Routes.styleguide_path(@socket, :typography)}
        replace={true}
        label="Typography"
        is_active={is_active?(@live_action, :typography)}
      />
      <.tab
        patch={Routes.styleguide_path(@socket, :form_fields)}
        replace={true}
        label="Form"
        is_active={is_active?(@live_action, :form_fields)}
      />
    </.tabs>
    <div class="mx-3">
      <%= case @live_action do %>
        <% :styleguide -> %>
          <.colors />
        <% :typography -> %>
          <.typography />
        <% :buttons -> %>
          <.buttons />
        <% :form_fields -> %>
          <.form_fields />
      <% end %>
    </div>
    """
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  defp is_active?(live_action, current) do
    if live_action == current do
      true
    end
  end
end

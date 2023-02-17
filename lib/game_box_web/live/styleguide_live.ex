defmodule GameBoxWeb.StyleguideLive do
  use GameBoxWeb, :live_view
  import GameBoxWeb.ColorSwatch

  alias GameBox.Styleguide
  alias GameBox.Styleguide.ExampleData

  embed_templates "styleguide/*"

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:example_data, %ExampleData{})
      |> assign(:changeset, Styleguide.change_example_data(%ExampleData{}))

    {:ok, socket}
  end

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
      <.tab
        patch={Routes.styleguide_path(@socket, :containers)}
        replace={true}
        label="Content Containers"
        is_active={is_active?(@live_action, :containers)}
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
          <.form_fields changeset={@changeset} />
        <% :containers -> %>
          <.containers />
      <% end %>
    </div>
    """
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "validate",
        %{"example_data" => example_data_params},
        %{assigns: %{example_data: example_data}} = socket
      ) do
    changeset =
      example_data
      |> Styleguide.change_example_data(example_data_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  defp is_active?(live_action, current) do
    if live_action == current do
      true
    end
  end
end

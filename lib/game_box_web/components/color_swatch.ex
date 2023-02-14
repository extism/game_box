defmodule GameBoxWeb.ColorSwatch do
  @moduledoc """
  Module for displaying a color swatch.
  """

  use Phoenix.Component
  import GameBoxWeb.ComponentHelpers

  attr(:color_class, :string, default: "", doc: "Add a color class")
  attr(:class, :string, default: "", doc: "CSS class")
  attr(:label, :string, default: nil, doc: "label your heading")
  attr(:rest, :global)
  slot(:inner_block, required: false)

  def color_swatch(assigns) do
    ~H"""
    <div class="flex flex-col mr-10 gap-y-2">
      <div class={get_swatch_classes("w-40 h-40", assigns)} {@rest}></div>
      <%= render_slot(@inner_block) || @label %>
    </div>
    """
  end

  defp get_swatch_classes(base_classes, assigns) do
    custom_classes = assigns[:class]
    color_classes = assigns[:color_class] || "bg-dark"

    build_class([base_classes, custom_classes, color_classes])
  end
end

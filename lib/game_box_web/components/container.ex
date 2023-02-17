defmodule GameBoxWeb.Container do
  use Phoenix.Component

  import GameBoxWeb.ComponentHelpers

  attr(:max_width, :string,
    default: "lg",
    values: ["sm", "md", "lg", "xl", "2xl", "full"],
    doc: "sets container max-width"
  )

  attr(:class, :string, default: "", doc: "CSS class for container")
  attr(:no_padding_on_mobile, :boolean, default: false, doc: "specify for padding on mobile")
  attr(:rest, :global)
  slot(:inner_block, required: false)

  @spec container(map) :: Phoenix.LiveView.Rendered.t()
  def container(assigns) do
    ~H"""
    <div
      {@rest}
      class={
        build_class([
          "container container-#{@max_width}",
          get_padding_class(@no_padding_on_mobile),
          @class
        ])
      }
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp get_padding_class(no_padding_on_mobile) do
    if no_padding_on_mobile, do: "", else: "pc-container--mobile-padded"
  end
end

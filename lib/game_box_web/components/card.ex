defmodule GameBoxWeb.Card do
  use Phoenix.Component

  import GameBoxWeb.ComponentHelpers
  import GameBoxWeb.Typography
  import GameBoxWeb.CoreComponents

  attr(:class, :string, default: "", doc: "CSS class")
  attr(:rest, :global)
  slot(:inner_block, required: false)

  def card(assigns) do
    ~H"""
    <div
      {@rest}
      class={
        build_class([
          "bg-dark rounded border border-zinc-700 w-full",
          @class
        ])
      }
    >
      <div class="">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  attr(:aspect_ratio_class, :string, default: "aspect-square", doc: "aspect ratio class")
  attr(:src, :string, default: nil, doc: "hosted image URL")
  attr(:class, :string, default: "", doc: "CSS class")
  attr(:rest, :global)
  slot(:inner_block, required: false)

  def card_media(assigns) do
    ~H"""
    <%= if @src do %>
      <img
        {@rest}
        src={@src}
        class={
          build_class(
            [
              @aspect_ratio_class,
              @class
            ],
            " "
          )
        }
      />
    <% else %>
      <div
        {@rest}
        class={
          build_class([
            @aspect_ratio_class,
            @class
          ])
        }
      >
      </div>
    <% end %>
    """
  end

  attr(:heading, :string, default: nil, doc: "creates a heading")
  attr(:author, :string, default: nil, doc: "creates a author")
  attr(:author_link, :string, default: nil, doc: "link to author's github or website")

  attr(:author_color_class, :string,
    default: "text-primary",
    doc: "sets a author color class"
  )

  attr(:class, :string, default: "", doc: "CSS class")
  attr(:rest, :global)
  slot(:inner_block, required: false)

  def card_content(assigns) do
    ~H"""
    <div
      {@rest}
      class={
        build_class([
          "p-6",
          @class
        ])
      }
    >
      <%= if @heading do %>
        <div>
          <.h4><%= @heading %></.h4>
        </div>
      <% end %>
      <%= if @author do %>
        <div class={"#{@author_color_class}"}>
          <%= if @author_link do %>
            <.link href={@author_link} target="_blank">
              <%= @author %>
            </.link>
          <% else %>
            <%= @author %>
          <% end %>
        </div>
      <% end %>
      <.p><%= render_slot(@inner_block) || @label %></.p>
    </div>
    """
  end

  attr(:class, :string, default: "", doc: "CSS class")
  attr(:rest, :global)
  slot(:inner_block, required: false)

  def card_footer(assigns) do
    ~H"""
    <div {@rest} class="pl-6 pb-6 w-full">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end

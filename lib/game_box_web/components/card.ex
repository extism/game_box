defmodule GameBoxWeb.Card do
  @moduledoc """
  A component for displaying content in a card. Allows for media, header, author, and paragraph content.
  """

  #   <.card>
  #   <.card_media src="/images/tictactoe.png" />
  #   <.card_content author="@bhelx" author_link="https://github.com/bhelx" heading="Tic Tac Toe">
  #     Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus eget leo interdum, feugiat
  #     ligula eu, facilisis massa. Nunc sollicitudin massa a elit laoreet.
  #   </.card_content>
  #   <.card_footer>
  #     <.button to="/" label="Join Now" class="w-full" />
  #     <.button to="/" label="Start" variant="outline" class="w-full" />
  #   </.card_footer>
  # </.card>

  use Phoenix.Component

  import GameBoxWeb.ComponentHelpers
  import GameBoxWeb.Typography

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
      <div class="flex flex-col justify-between h-full">
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
      <div
        class="w-full flex justify-center h-64 bg-cover bg-center"
        style={"background-image:url(#{@src})"}
      >
      </div>
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
          "p-6 flex-grow flex-1",
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
      <%= if Enum.any?(@inner_block) || not is_nil(assigns[:label]) do %>
        <.p><%= render_slot(@inner_block) || @label %></.p>
      <% end %>
    </div>
    """
  end

  attr(:class, :string, default: "", doc: "CSS class")
  attr(:rest, :global)
  slot(:inner_block, required: false)

  def card_footer(assigns) do
    ~H"""
    <div {@rest} class="px-6 pb-6 w-full">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end

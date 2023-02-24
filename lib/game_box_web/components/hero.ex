defmodule GameBoxWeb.Hero do
  use Phoenix.Component
  import GameBoxWeb.Typography

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  attr :subheader, :string, default: nil
  attr :header, :string, default: nil
  attr :subtext, :string, default: nil
  attr :class, :string, default: nil

  def hero(assigns) do
    ~H"""
    <div class={"#{@class} my-24"}>
      <.h5 :if={@subheader} class="text-center !text-primary" label={@subheader} />
      <.h1 :if={@header} class="text-center" label={@header} />
      <.p :if={@subtext} class="text-center"><%= @subtext %></.p>
    </div>
    """
  end
end

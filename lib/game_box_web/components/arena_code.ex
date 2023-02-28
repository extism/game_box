defmodule GameBoxWeb.ArenaCode do
  @moduledoc """
  A component for displaying the Arena Code and a copy link.
  """
  use Phoenix.Component

  import GameBoxWeb.Typography
  alias Phoenix.LiveView.JS

  def arena_code(assigns) do
    ~H"""
    <.h5 class="!text-primary !pt-0 !mt-0" label="Arena" />
    <.h1 :if={@arena_id} label={@arena_id} />

    <.p class="text-sm">
      Have your friends enter this code at gamebox.fly.dev to join!
    </.p>

    <div>
      <.p class="text-secondary text-sm !m-0">
        Or
        <a
          class="cursor-pointer underline text-primary hover:text-white"
          phx-click={JS.dispatch("gamebox:clipcopy", to: "#arena-code")}
        >
          copy an invite link
        </a>
        <div class="copied hidden text-xs italic">Copied!</div>
      </.p>

      <input type="hidden" id="arena-code" value={"gamebox.fly.dev/join?arena=#{@arena_id}"} />
    </div>
    """
  end
end

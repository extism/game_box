defmodule GameBoxWeb.ArenaCode do
  @moduledoc """
  A component for displaying the Arena Code and a copy link.
  """
  use Phoenix.Component

  import GameBoxWeb.Typography
  alias GameBox.Arena
  alias Phoenix.LiveView.JS

  def arena_code(assigns) do
    ~H"""
    <.h5 class="!text-primary !pt-0 !mt-0" label="Arena" />
    <.h1 :if={@arena_id} label={@arena_id} />

    <.p class="text-sm">
      Have your friends enter this code at <%= @uri %> to join!
    </.p>

    <div>
      <div class="w-5/6">
        <label for="email" class="block text-sm text-secondary">Or copy invite link:</label>
        <div class="mt-1 flex rounded-md shadow-sm">
          <div class="relative flex flex-grow items-stretch focus-within:z-10">
            <input
              id="arena-code"
              class={[
                "block w-full rounded-lg py-[7px] px-[11px] bg-dark border border-zinc-800",
                "text-white focus:outline-none focus:ring-4 sm:text-xs sm:leading-6",
                "border-zinc-700 focus:border-primary-dark focus:ring-zinc-800/5"
              ]}
              value={"#{@uri}/?arena=#{Arena.normalize_id(@arena_id)}"}
            />
          </div>

          <button
            phx-click={JS.dispatch("gamebox:clipcopy", to: "#arena-code")}
            type="button"
            class="relative -ml-px inline-flex items-center rounded-r-md border border-zinc-800 bg-dark px-2 py-1 text-sm font-medium text-primary hover:bg-primary hover:text-white focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary"
          >
            <span>Copy</span>
          </button>
        </div>
      </div>

      <div class="copied hidden text-xs italic">Copied!</div>
    </div>
    """
  end
end

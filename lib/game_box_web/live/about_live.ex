defmodule GameBoxWeb.AboutLive do
  use GameBoxWeb, :live_view

  alias GameBox.Games

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:games, Games.list_games())

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.hero
      header="About Gamebox"
      subtext="Gamebox is lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur ut arcu gravida mauris hendrerit vehicula at nec lacus. Maecenas sed dolor eget nisl commodo condimentum luctus vitae risus.
    "
    />

    <div class="flex flex-col md:flex-row">
      <div class="w-full text-center">
        <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-x-6 gap-y-6 md:gap-x-12 md:gap-y-12 mb-12">
          <%= for game <- @games do %>
            <.card>
              <.card_media :if={game.artwork} src={game.artwork} />
              <.card_media
                :if={!game.artwork}
                src="/images/donut.png"
                class="flex justify-center w-48 p-6"
              />
              <.card_content
                author={"@#{game.user.gh_login}"}
                author_link={"https://github.com/#{game.user.gh_login}"}
                heading={game.title}
              />
              <.card_footer>
                <.button
                  phx-click="select_game"
                  phx-value-game_id={game.id}
                  label="View Details"
                  class="w-full"
                />
              </.card_footer>
            </.card>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end

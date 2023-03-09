defmodule GameBoxWeb.AboutLive do
  use GameBoxWeb, :live_view

  def render(assigns) do
    ~H"""
    <.hero header="About Gamebox" />
    <div class="flex flex-col items-center justify-center text-center">
      <.p>
        Some About Info
      </.p>
      <.link class="text-primary text-xl" href={~p"/auth/github"}>Sign in with Github</.link>
    </div>
    """
  end
end

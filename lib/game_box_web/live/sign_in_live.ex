defmodule GameBoxWeb.SignInLive do
  use GameBoxWeb, :live_view

  def render(assigns) do
    ~H"""
    <.hero header="Sign In" />
    <div class="flex flex-col items-center justify-center text-center">
      <.p>
        To upload a game, you must first sign in through Github. Click the link below to authorize GameBox.
      </.p>
      <.link class="text-primary text-xl" href={~p"/auth/github"}>Sign in with Github</.link>
    </div>
    """
  end
end

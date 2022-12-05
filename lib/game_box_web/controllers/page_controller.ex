defmodule GameBoxWeb.PageController do
  use GameBoxWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

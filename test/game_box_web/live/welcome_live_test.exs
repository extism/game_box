defmodule GameBoxWeb.WelcomeLiveTest do
  @moduledoc false
  use GameBoxWeb.ConnCase

  describe "welcome" do
    test "renders welcome page", %{conn: conn} do
      {:ok, _view, html} =
        live(conn, Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.WelcomeLive))

      assert html =~ "Welcome to GameBox"
    end
  end
end

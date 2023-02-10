defmodule GameBoxWeb.AuthControllerTest do
  @moduledoc false

  use GameBoxWeb.ConnCase
  alias GameBoxWeb.AuthController
  alias Phoenix.Flash

  describe "auth/github/callback/2" do
    test "can handle a successful response from github", %{conn: conn} do
      %{extra: %{raw_info: %{user: %{"login" => gh_login}}}} =
        ueberauth_response = build(:ueberauth)

      conn =
        conn
        |> bypass_through(GameBoxWeb.Router, [:browser])
        |> get("/auth/github/callback")
        |> assign(:ueberauth_auth, ueberauth_response)
        |> AuthController.callback(%{})

      assert Flash.get(conn.assigns.flash, :info) ==
               "Successfully authenticated #{gh_login}"

      assert redirected_to(conn) == Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.HomeLive)
    end

    test "can handle a fail response from github", %{conn: conn} do
      conn =
        conn
        |> bypass_through(GameBoxWeb.Router, [:browser])
        |> get("/auth/github/callback")
        |> assign(:ueberauth_failure, %{})
        |> AuthController.callback(%{})

      assert Flash.get(conn.assigns.flash, :error) == "Failed to authenticate."

      assert redirected_to(conn) == Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.WelcomeLive)
    end
  end

  describe "auth/delete/2" do
    test "can log a user out", %{conn: conn} do
      conn = get(conn, Routes.auth_path(conn, :delete))

      assert Flash.get(conn.assigns.flash, :info) == "You have been logged out!"
      assert redirected_to(conn) == Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.WelcomeLive)
    end
  end
end

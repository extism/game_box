defmodule GameBoxWeb.UploadLiveTest do
  @moduledoc false

  use GameBoxWeb.ConnCase

  describe "mount" do
    test "redirects to welcome path when unauthenticated", %{conn: conn} do
      welcome_path = Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.WelcomeLive)

      assert {:error,
              {:redirect,
               %{
                 flash: %{"info" => "You must be logged in to view this page."},
                 to: ^welcome_path
               }}} = live(conn, Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.UploadLive))
    end

    test "mounts to upload page when authenticated", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> assign(:current_user, user)
        |> put_session(:user_id, user.id)

      assert {:ok, _view, _html} =
               live(conn, Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.UploadLive))
    end
  end

  # NOTE: this test relies on the tictactoe.wasm matching the game api
  describe "uploading a game" do
    setup %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> assign(:current_user, user)
        |> put_session(:user_id, user.id)

      # We need to create this directory because it is gitignored
      File.mkdir_p("priv/static/uploads")

      {:ok, conn: conn}
    end

    test "will return a flash for invalid attributes", %{conn: conn} do
      {:ok, view, _html} =
        live(conn, Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.UploadLive))

      assert render_submit(view, "upload_game", %{"game" => %{"title" => ""}}) =~
               "Game could not be uploaded."
    end

    test "upload game with valid attributes", %{conn: conn} do
      {:ok, view, _html} =
        live(conn, Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.UploadLive))

      params = %{
        "title" => "Tic Tac Toe",
        "description" => "a classic game of tic tac toe"
      }

      game =
        file_input(view, "#upload-game-form", :game, [
          %{
            last_modified: :os.system_time(:millisecond),
            name: "my-awesome-game.wasm",
            content: File.read!("tictactoe.wasm"),
            size: 3_890_274,
            type: "application/octet-stream"
          }
        ])

      html =
        view
        |> element("form")
        |> render_change(%{"game" => params})

      assert html =~ "Tic Tac Toe"
      assert html =~ "a classic game of tic tac toe"

      html_after_upload = render_upload(game, "my-awesome-game.wasm")

      # We assert the html after the upload has been triggered to ensure that form values are
      # properly reset on the changeset in the validate handle_event
      assert html_after_upload =~ "Tic Tac Toe"
      assert html_after_upload =~ "a classic game of tic tac toe"

      assert render_submit(view, "upload_game", %{"game" => params}) =~
               "Game successfully uploaded!"
    end
  end
end

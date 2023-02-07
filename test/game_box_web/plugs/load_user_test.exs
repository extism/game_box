defmodule GameBoxWeb.LoadUserTest do
  @moduledoc false

  use GameBoxWeb.ConnCase
  import GameBox.Factory
  alias GameBoxWeb.LoadUser
  alias Plug.Conn

  setup do
    {:ok, user: insert(:user)}
  end

  describe "call/2" do
    test "will assign current_user from user_id session value", %{conn: conn, user: user} do
      conn =
        conn
        |> Plug.Test.init_test_session(user_id: user.id)
        |> LoadUser.call([])

      assert %{assigns: %{current_user: ^user}} = conn
    end

    test "will assign current_user from existing user assign", %{conn: conn, user: user} do
      conn =
        conn
        |> Conn.assign(:current_user, user)
        |> LoadUser.call([])

      assert %{assigns: %{current_user: ^user}} = conn
    end

    test "will reset user_id session and current_user assign when missing requirements", %{
      conn: conn
    } do
      conn = LoadUser.call(conn, [])

      refute get_session(conn, :user_id)
      assert %{assigns: %{current_user: nil}} = conn
    end
  end
end

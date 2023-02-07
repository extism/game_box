defmodule GameBox.UsersTest do
  @moduledoc false

  use GameBox.DataCase
  alias GameBox.Users

  setup do
    {:ok, user: insert(:user)}
  end

  describe "get_user/1" do
    test "returns the user based on id", %{user: %{id: id} = user} do
      assert Users.get_user(id) == user
    end
  end

  describe "get_user_by_gh_id/1" do
    test "returns the user based on matching gh_id", %{user: %{gh_id: gh_id} = user} do
      assert Users.get_user_by_gh_id(gh_id) == user
    end
  end

  describe "find_or_create_user/1" do
    test "can return an existing user", %{user: %{id: user_id} = user} do
      auth = %{extra: %{raw_info: %{user: %{"login" => user.gh_login, "id" => user.gh_id}}}}

      assert {:ok, %{id: ^user_id}} = Users.find_or_create_user(auth)
    end

    test "can create a new user if it does not exist" do
      auth = %{
        extra: %{raw_info: %{user: %{"login" => "gamedev100", "id" => 0}}}
      }

      assert {:ok, %GameBox.User{gh_id: 0, gh_login: "gamedev100"}} =
               Users.find_or_create_user(auth)
    end
  end
end

defmodule GameBox.Factory do
  @moduledoc """
  ExMachina factory module for defining test data
  """
  alias GameBox.Repo
  use ExMachina.Ecto, repo: Repo

  def user_factory do
    %GameBox.User{
      gh_id: sequence(:gh_id, &"#{&1}"),
      gh_login: "superdev",
      is_banned: false
    }
  end

  def ueberauth_factory do
    %Ueberauth.Auth{
      provider: :github,
      uid: sequence(:uid, &"#{&1}"),
      info: %Ueberauth.Auth.Info{},
      extra: %Ueberauth.Auth.Extra{
        raw_info: %{
          user: %{
            "login" => "gamedev_#{System.unique_integer([:positive])}",
            "id" => sequence(:gh_id, &"#{&1}")
          }
        }
      }
    }
  end

  def game_factory do
    %GameBox.Games.Game{
      title: sequence(:title, &"Game #{&1}"),
      description: "a very fun game to play!",
      path: "tictactoe.wasm",
      user: build(:user)
    }
  end
end

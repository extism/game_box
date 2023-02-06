defmodule GameBox.Users do
  @moduledoc """
  Context for interacting with the %User{} schema
  """
  alias GameBox.{Repo, User}
  import Ecto.Query

  @spec get_user(integer()) :: User.t() | nil
  def get_user(id) do
    Repo.get(User, id)
  end

  @spec get_user_by_gh_id(integer()) :: User.t() | nil
  def get_user_by_gh_id(gh_id) do
    User
    |> where([u], u.gh_id == ^gh_id)
    |> Repo.one()
  end

  @spec find_or_create_user(map()) :: {:ok, User.t()} | {:error, %Ecto.Changeset{}}
  def find_or_create_user(%{extra: %{raw_info: %{user: %{"login" => login, "id" => id}}}}) do
    case get_user_by_gh_id(id) do
      nil -> create_user(%{gh_id: id, gh_login: login})
      user -> {:ok, user}
    end
  end

  @spec create_user(map()) :: {:ok, User.t()} | {:error, %Ecto.Changeset{}}
  defp create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end

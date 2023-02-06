defmodule GameBox.Repo.Migrations.AddUsersTable do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:gh_id, :bigint)
      add(:gh_login, :string)
      add(:is_banned, :boolean, default: false)

      timestamps()
    end
  end
end

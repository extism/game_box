defmodule GameBox.Repo.Migrations.AddUserIdToGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :user_id, references(:users)
      add :description, :text
    end

    create index(:games, [:user_id])
  end
end

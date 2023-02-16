defmodule GameBox.Repo.Migrations.AddArtWorkToGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :artwork, :string
    end
  end
end

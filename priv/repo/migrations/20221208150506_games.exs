defmodule GameBox.Repo.Migrations.Games do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :title, :string
      add :path, :string
      timestamps()
    end
  end
end

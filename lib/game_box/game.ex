defmodule GameBox.Games.Game do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  schema "games" do
    field :title, :string
    field :path, :string
    timestamps()
  end

  def changeset(game, attrs) do
    game
    |> cast(attrs, [:title, :path])
    |> validate_required([:title, :path])
  end
end

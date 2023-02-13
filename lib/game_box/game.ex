defmodule GameBox.Games.Game do
  @moduledoc false
  alias GameBox.User

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}
  schema "games" do
    field(:title, :string)
    field(:path, :string)
    field(:artwork, :string)
    field(:description, :string)
    belongs_to(:user, User)
    timestamps()
  end

  def changeset(game, attrs) do
    game
    |> cast(attrs, [:title, :path, :user_id, :description, :artwork])
    |> validate_required([:title, :path, :user_id, :description, :artwork])
  end
end

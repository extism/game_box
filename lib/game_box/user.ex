defmodule GameBox.User do
  @moduledoc """
    Schema to associate GitHub Authenticated "Game creator"
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}
  schema "users" do
    field(:gh_id, :integer)
    field(:gh_login, :string)
    field(:is_banned, :boolean)
    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:gh_id, :gh_login, :is_banned])
    |> validate_required([:gh_id, :gh_login])
  end
end

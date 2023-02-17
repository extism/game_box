defmodule GameBox.Styleguide.ExampleData do
  @moduledoc """
  The datastructure for the styleguide form.
  """
  import Ecto.Changeset

  defstruct [:email, :comment, :fruit, :agree]
  @types %{comment: :string, email: :string, fruit: :string, agree: :boolean}

  def changeset(%__MODULE__{} = user, attrs) do
    {user, @types}
    |> cast(attrs, Map.keys(@types))
    |> validate_required([:email, :comment, :agree, :fruit])
    |> validate_format(:email, ~r/@/)
  end
end

defmodule GameBox.Arena.Player do
  defstruct id: nil, name: nil

  @type t :: %__MODULE__{
    id: String.t(),
    name: String.t()
  }

  def new(name) do
    %__MODULE__{
      id: Ecto.UUID.generate(),
      name: name
    }
  end
end

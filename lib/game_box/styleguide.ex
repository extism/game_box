defmodule GameBox.Styleguide do
  @moduledoc """
  The context for the styleguide form.
  """
  alias GameBox.Styleguide.ExampleData

  def change_example_data(%ExampleData{} = example_data, attrs \\ %{}) do
    ExampleData.changeset(example_data, attrs)
  end
end

defmodule GameBoxWeb.Code do
  @moduledoc """
  A component used for displaying code samples in documentation
  <.code />
  """
  use Phoenix.Component
  import Phoenix.HTML, only: [raw: 1]

  def code(assigns) do
    ~H"""
    <code>
      <pre class="p-5 text-white bg-black border-l border-l-3 border-zinc-300"><%= HtmlEntities.decode(@content) %></pre>
    </code>
    """
  end
end

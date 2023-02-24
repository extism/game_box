defmodule GameBoxWeb.Code do
  @moduledoc """
  A component used for displaying code samples in documentation
  <.code />
  """
  use Phoenix.Component

  def code(assigns) do
    ~H"""
    <code class="max-w-full">
      <pre class="p-5 text-white bg-black border-l border-l-3 border-zinc-300 !max-w-full  overflow-scroll"><%= HtmlEntities.decode(@content) %></pre>
    </code>
    """
  end
end

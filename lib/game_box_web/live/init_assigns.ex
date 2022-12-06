defmodule GameBoxWeb.InitAssigns do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(:default, _params, session, socket) do
    {:cont, assign(socket, :username, Map.get(session, "username", :unset))}
  end
end

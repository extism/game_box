defmodule GameBoxWeb.InitAssigns do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """

  def on_mount(:default, _params, _session, socket) do
    {:cont, socket}
  end
end

defmodule GameBoxWeb.SessionPlug do
  @moduledoc false

  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    player_id = get_session(conn, :player_id)

    if is_nil(player_id) do
      put_session(conn, :player_id, Ecto.UUID.generate())
    else
      conn
    end
  end
end

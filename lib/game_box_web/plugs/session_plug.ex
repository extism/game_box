defmodule GameBoxWeb.SessionPlug do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    if is_nil(user_id) do
      put_session(conn, :user_id, Ecto.UUID.generate())
    else
      conn
    end
  end
end

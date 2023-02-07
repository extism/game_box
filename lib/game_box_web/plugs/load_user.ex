defmodule GameBoxWeb.LoadUser do
  @moduledoc """
    Plug to load user from the session
  """

  import Plug.Conn
  alias GameBox.Users

  def init(opts), do: opts

  def call(conn, _) do
    user_id = get_session(conn, :user_id)

    cond do
      user = conn.assigns[:current_user] ->
        assign(conn, :current_user, user)

      user = user_id && Users.get_user(user_id) ->
        conn
        |> put_session(:user_id, user_id)
        |> assign(:current_user, user)

      true ->
        conn
        |> put_session(:user_id, nil)
        |> assign(:current_user, nil)
    end
  end
end

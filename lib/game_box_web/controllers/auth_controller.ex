defmodule GameBoxWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """

  use GameBoxWeb, :controller
  alias GameBox.User
  alias GameBox.Users
  plug(Ueberauth)

  @spec delete(Plug.Conn.t(), any) :: Plug.Conn.t()
  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> clear_session()
    |> redirect(to: Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.WelcomeLive))
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    handle_failure(conn)
  end

  @spec callback(Plug.Conn.t(), any) :: Plug.Conn.t()
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case Users.find_or_create_user(auth) do
      {:ok, %User{} = user} ->
        handle_success(conn, user)

      {:error, _error} ->
        handle_failure(conn)
    end
  end

  defp handle_success(conn, user) do
    conn
    |> put_flash(:info, "Successfully authenticated #{user.gh_login}")
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
    |> redirect(to: Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.HomeLive))
  end

  defp handle_failure(conn) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: Routes.live_path(GameBoxWeb.Endpoint, GameBoxWeb.WelcomeLive))
  end
end

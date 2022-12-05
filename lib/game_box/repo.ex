defmodule GameBox.Repo do
  use Ecto.Repo,
    otp_app: :game_box,
    adapter: Ecto.Adapters.Postgres
end

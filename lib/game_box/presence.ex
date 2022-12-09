defmodule GameBox.Presence do
  use Phoenix.Presence,
    otp_app: :game_box,
    pubsub_server: GameBox.PubSub
end

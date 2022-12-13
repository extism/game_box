defmodule GameBox.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      # Start the Ecto repository
      GameBox.Repo,
      # Start the Telemetry supervisor
      GameBoxWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: GameBox.PubSub},
      # Start a worker by calling: GameBox.Worker.start_link(arg)
      # {GameBox.Worker, arg}
      {Cluster.Supervisor, [topologies, [name: GameBox.ClusterSupervisor]]},
      {Horde.Registry, [name: GameBox.PlayersRegistry, keys: :unique, members: :auto]},
      {Horde.Registry, [name: GameBox.ArenaRegistry, keys: :unique, members: :auto]},
      {Horde.DynamicSupervisor,
       [
         name: GameBox.DistributedSupervisor,
         shutdown: 1000,
         strategy: :one_for_one,
         members: :auto
       ]},
      # Start the Endpoint (http/https)
      GameBoxWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GameBox.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GameBoxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

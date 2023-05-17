defmodule Amphi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      AmphiWeb.Telemetry,
      # Start the Ecto repository
      Amphi.Repo,
      # Start the Ecto repository
      Amphi.MongoDBRepo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Amphi.PubSub},
      # Start Finch
      {Finch, name: Amphi.Finch},
      # Start the Endpoint (http/https)
      AmphiWeb.Endpoint
      # Start a worker by calling: Amphi.Worker.start_link(arg)
      # {Amphi.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Amphi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AmphiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

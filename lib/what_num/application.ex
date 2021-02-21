defmodule WhatNum.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      WhatNumWeb.Telemetry,
      {Phoenix.PubSub, name: WhatNum.PubSub},
      WhatNumWeb.Endpoint
    ]

    # Start Neural net training
    TrainingCache.start_link( MNIST.run())

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WhatNum.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    WhatNumWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

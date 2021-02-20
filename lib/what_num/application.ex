defmodule WhatNum.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      WhatNumWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: WhatNum.PubSub},
      # Start the Endpoint (http/https)
      WhatNumWeb.Endpoint
      # Start a worker by calling: WhatNum.Worker.start_link(arg)
      # {WhatNum.Worker, arg}
    ]

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

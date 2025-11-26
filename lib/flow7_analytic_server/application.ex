defmodule Flow7AnalyticServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Flow7AnalyticServerWeb.Telemetry,
      Flow7AnalyticServer.Repo,
      {DNSCluster, query: Application.get_env(:flow7_analytic_server, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Flow7AnalyticServer.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Flow7AnalyticServer.Finch},
      # Start a worker by calling: Flow7AnalyticServer.Worker.start_link(arg)
      # {Flow7AnalyticServer.Worker, arg},
      # Start to serve requests, typically the last entry
      Flow7AnalyticServerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Flow7AnalyticServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Flow7AnalyticServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

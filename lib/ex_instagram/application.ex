defmodule ExInstagram.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ExInstagramWeb.Telemetry,
      ExInstagram.Repo,
      {DNSCluster, query: Application.get_env(:ex_instagram, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ExInstagram.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ExInstagram.Finch},
      ExInstagram.AiSupervisor,
      # Start to serve requests, typically the last entry
      ExInstagramWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExInstagram.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ExInstagramWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule CrackHashManager.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias CrackHashManager.Clients.Workers, as: WorkersClient

  @doc false
  @impl true
  def start(_type, _args) do
    children = [
      {Bandit,
       plug: CrackHashManagerWeb.Endpoint,
       scheme: :http,
       options: [port: CrackHashManager.fetch_env!(:endpoint, :port)]},
      {Finch, name: CrackHashManager.FinchHTTP},
      {Mongo,
       [
         name: :mongo,
         database: CrackHashManager.fetch_env!(:mongo, :database),
         pool_size: 10,
         seeds: CrackHashManager.fetch_env!(:mongo, :seeds)
       ]},
      {Task.Supervisor, name: CrackHashManager.WorkersSupervisor},
      {DynamicSupervisor, strategy: :one_for_one, name: CrackHashManager.JobsStorageSupervisor},
      CrackHashManager.Scheduler,
      {CrackHashManagerWeb.RMQEndpoint, []},
      {Registry, keys: :unique, name: CrackHashManager.JobsStorageRegistry}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CrackHashManager.Supervisor]
    res = Supervisor.start_link(children, opts)
    WorkersClient.init()
    res
  end
end

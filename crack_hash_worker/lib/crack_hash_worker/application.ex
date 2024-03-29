defmodule CrackHashWorker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias CrackHashWorker.Clients.Manager, as: ManagerClient

  @impl true
  def start(_type, _args) do
    children = [
      {Bandit,
       plug: CrackHashWorkerWeb.Endpoint,
       scheme: :http,
       options: [port: CrackHashWorker.fetch_env!(:endpoint, :port)]},
      {Finch, name: CrackHashWorker.FinchHTTP},
      CrackHashWorkerWeb.RMQEndpoint,
      {Task.Supervisor, name: CrackHashWorker.WorkerSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CrackHashWorker.Supervisor]
    res = Supervisor.start_link(children, opts)
    ManagerClient.init()
    res
  end
end

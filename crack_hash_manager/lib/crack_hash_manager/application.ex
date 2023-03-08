defmodule CrackHashManager.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Bandit,
       plug: CrackHashManagerWeb.Endpoint,
       scheme: :http,
       options: [port: CrackHashManager.fetch_env!(:endpoint, :port)]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CrackHashManager.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

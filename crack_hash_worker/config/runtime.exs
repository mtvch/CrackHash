import Config

rmq_url =
  if config_env() == :prod do
    System.fetch_env!("RMQ_URL")
  else
    "amqp://guest:guest@127.0.0.1:5672"
  end

if config_env() == :prod do
  config :crack_hash_worker, :endpoint, port: System.fetch_env!("PORT") |> String.to_integer()

  # config :crack_hash_worker, CrackHashWorker.Clients.Manager.Real,
  #   manager_endpoint: System.fetch_env!("MANAGER_ENDPOINT")
end

if config_env() in [:dev, :prod] do
  # amqp приложение само создает соединения и каналы и пытается восстановить их, если соединениe потеряно
  # https://hexdocs.pm/amqp/AMQP.Application.html
  config :amqp,
    connections: [
      default: [
        # System.fetch_env!("RMQ_URL"),
        url: rmq_url,
        virtual_host: "/"
      ]
    ],
    channels: [
      producer: [connection: :default],
      consumer: [connection: :default]
    ]

  config :crack_hash_worker, CrackHashWorker.Clients.Manager,
    client: CrackHashWorker.Clients.Manager.RMQReal

  config :crack_hash_worker, CrackHashWorker.Clients.Manager.RMQReal,
    exchange: "services",
    routing_key: "manager"

  config :crack_hash_worker, CrackHashWorkerWeb.RMQEndpoint, queue: "worker", rmq_url: rmq_url
end

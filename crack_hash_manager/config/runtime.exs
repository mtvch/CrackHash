import Config

rmq_url =
  if config_env() == :prod do
    System.fetch_env!("RMQ_URL")
  else
    "amqp://guest:guest@127.0.0.1:5672"
  end

if config_env() == :dev do
  config :crack_hash_manager, :mongo,
    database: "crack_hash_maneger_dev",
    seeds: ["localhost:30001", "localhost:30002"]

  config :crack_hash_manager, CrackHashManager.Clients.Workers.RMQReal,
    workers_count: 2,
    exchange: "services",
    routing_key: "workers"
end

if config_env() == :prod do
  config :crack_hash_manager, :mongo,
    database: "crack_hash_maneger_prod",
    seeds: System.fetch_env!("MONGO_SEEDS") |> String.split(",")

  config :crack_hash_manager, CrackHashManager.Clients.Workers.RMQReal,
    workers_count: System.fetch_env!("WORKERS_COUNT") |> String.to_integer(),
    exchange: "services",
    routing_key: "workers"
end

if config_env() in [:dev, :prod] do
  config :crack_hash_manager, CrackHashManager.Clients.Workers,
    client: CrackHashManager.Clients.Workers.RMQReal

  config :crack_hash_manager, CrackHashManager.Scheduler,
    jobs: [
      # Every minute
      {"* * * * *", {CrackHashManager.Sender, :resend, []}}
    ]

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
      # В него мы будем отправлять сообщения
      producer: [connection: :default],
      consumer: [connection: :default]
    ]

  config :crack_hash_manager, CrackHashManagerWeb.RMQEndpoint, queue: "manager", rmq_url: rmq_url
end

import Config

config :logger, :console, level: :critical

config :crack_hash_manager, :mongo,
  database: "crack_hash_manager_test",
  seeds: ["localhost:30001", "localhost:30002"]

config :crack_hash_manager, CrackHashManagerWeb.RMQEndpoint,
  queue: "manager",
  rmq_url: "amqp://guest:guest@127.0.0.1:5672"

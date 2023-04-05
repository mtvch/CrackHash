import Config

config :logger, :console, level: :critical

config :crack_hash_worker, CrackHashWorkerWeb.RMQEndpoint,
  queue: "worker",
  rmq_url: "amqp://guest:guest@127.0.0.1:5672"

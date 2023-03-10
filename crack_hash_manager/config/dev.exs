import Config

config :crack_hash_manager, CrackHashManager.Clients.Workers, workers: ["localhost:4001"]

config :logger, :console,
  level: :info,
  format: "[$level] $message [$metadata]\n",
  metadata: [:pid, :file, :line]

import Config

config :logger, :console,
  level: :info,
  format: "[$level] $message [$metadata]\n",
  metadata: [:pid, :file, :line]

config :crack_hash_manager, CrackHashManager.Clients.Workers,
  client: CrackHashManager.Clients.Workers.Real

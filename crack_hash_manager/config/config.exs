import Config

config :crack_hash_manager, :endpoint, port: 4000

config :crack_hash_manager, CrackHashManager.Clients.Workers,
  client: CrackHashManager.Clients.Workers.Stub

config :crack_hash_manager, CrackHashManager.Clients.Workers.Real,
  workers_endpoints: ["http://localhost:4001"]

config :logger, :console,
  level: :info,
  format: "[$level] $message [$metadata]\n",
  metadata: [:pid, :file, :line]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

import Config

config :crack_hash_worker, :endpoint, port: 4001

config :crack_hash_worker, CrackHashWorker.Clients.Manager,
  client: CrackHashWorker.Clients.Manager.Stub

config :crack_hash_worker, CrackHashWorker.Clients.Manager.Real,
  manager_endpoint: "http://localhost:4000"

config :logger, :console,
  level: :info,
  format: "[$level] $time $message [$metadata]\n",
  metadata: [:pid, :file, :line]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

import Config

config :crack_hash_manager, :endpoint, port: 4000

config :crack_hash_manager, CrackHashManager.Clients.Workers,
  client: CrackHashManager.Clients.Workers.Stub

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

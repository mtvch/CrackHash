import Config

config :crack_hash_worker, CrackHashWorker.Clients.Manager,
  client: CrackHashWorker.Clients.Manager.Real

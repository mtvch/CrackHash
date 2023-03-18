import Config

if CrackHashWorker.env() == :prod do
  config :crack_hash_worker, CrackHashWorker.Clients.Manager.Real,
    manager_endpoint: System.fetch_env!("MANAGER_ENDPOINT")
end

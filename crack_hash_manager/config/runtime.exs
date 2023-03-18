import Config

if CrackHashManager.env() == :prod do
  config :crack_hash_manager, CrackHashManager.Clients.Workers.Real,
    workers_endpoints: System.fetch_env!("WORKERS_ENDPOINTS") |> String.split(",")
end

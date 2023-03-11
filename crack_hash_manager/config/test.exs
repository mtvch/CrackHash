import Config

config :logger, :console,
  level: :critical,
  format: "[$level] $message [$metadata]\n",
  metadata: [:pid, :file, :line]

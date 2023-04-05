defmodule CrackHashManager.Scheduler do
  @moduledoc """
  Данный модуль нужен для выполнения периодических задач библиотекой Quantum
  """
  use Quantum, otp_app: :crack_hash_manager
end

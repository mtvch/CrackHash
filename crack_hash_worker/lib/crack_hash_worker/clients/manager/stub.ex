defmodule CrackHashWorker.Clients.Manager.Stub do
  @moduledoc """
  Затычка для клиента для отправки результатов менеджеру
  """

  alias CrackHashWorker.Clients.Manager, as: ManagerClient
  alias CrackHashWorker.Clients.Manager.DTO

  @behaviour ManagerClient

  @impl true
  @doc false
  def send_result(%DTO{}), do: :ok
end

defmodule CrackHashManager.Clients.Workers.Stub do
  @moduledoc """
  Затычка для клиента для взаимодействия с воркерами
  """

  alias CrackHashManager.Clients.Workers, as: WorkersClient
  alias CrackHashManager.Clients.Workers.DTO

  @behaviour WorkersClient

  @doc false
  def workers_count, do: 2

  @doc false
  def send(%DTO{}), do: :ok
end

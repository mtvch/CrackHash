defmodule CrackHashManager.Clients.Workers do
  @moduledoc """
  Клиент для взаимодействия с воркерами
  """

  defmodule DTO do
    @moduledoc """
    Data Transfer Object: Структура, которую принимает на вход клиент
    """
    defstruct [:request_id, :part_number, :part_count, :hash, :max_length, :alphabet]

    @type t :: %__MODULE__{
            request_id: String.t(),
            part_number: integer(),
            part_count: integer(),
            hash: String.t(),
            max_length: integer(),
            alphabet: String.t()
          }
  end

  @callback workers_count() :: integer()
  @callback send(DTO.t()) :: :ok

  @doc """
  Возвращает число воркеров
  """
  @spec workers_count() :: integer()
  def workers_count, do: client().workers_count()

  @doc """
  Отправляет запрос одному из воркеров
  """
  @spec send(DTO.t()) :: :ok
  def send(%DTO{} = dto), do: client().send(dto)

  defp client, do: CrackHashManager.fetch_env!(__MODULE__, :client)
end

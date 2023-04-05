defmodule CrackHashWorker.Clients.Manager do
  @moduledoc """
  Клиент для взаимодействия с менеджером воркеров.
  """

  defmodule DTO do
    @moduledoc """
    Data Transfer Object: Структура, которую принимает на вход клиент
    """
    defstruct [:request_id, :part_number, :answers]

    @type t :: %__MODULE__{
            request_id: String.t(),
            part_number: integer(),
            answers: [String.t()]
          }
  end

  @callback init() :: :ok
  @callback send_result(DTO.t()) :: :ok

  @doc """
  Выполняет инициализацию клиента. Вызывается на старте приложения
  """
  @spec init() :: :ok
  def init, do: client().init()

  @doc """
  Отправляет ответ с результатом работы воркера менеджеру
  """
  @spec send_result(DTO.t()) :: :ok
  def send_result(%DTO{} = dto), do: client().send_result(dto)

  defp client, do: CrackHashWorker.fetch_env!(__MODULE__, :client)
end

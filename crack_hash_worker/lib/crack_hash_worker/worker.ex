defmodule CrackHashWorker.Worker do
  @moduledoc """
  Взламывает хэш методом брут-форса
  """
  require Logger

  alias CrackHashWorker.Clients.Manager, as: ManagerClient
  alias CrackHashWorker.Math
  alias CrackHashWorker.WorkerSupervisor

  defmodule DTO do
    @moduledoc """
    Data Transfer Object для взаимодействия с воркером
    """
    defstruct [:request_id, :hash, :max_length, :part_number, :part_count, :alphabet]

    @type t :: %__MODULE__{
            request_id: String.t(),
            hash: String.t(),
            max_length: pos_integer(),
            part_number: pos_integer(),
            part_count: pos_integer(),
            alphabet: String.t()
          }
  end

  @doc """
  Запускает процесс по взлому хэша
  """
  @spec start_job(DTO.t()) :: :ok
  def start_job(%DTO{} = dto) do
    Logger.info("Начинаю взлом хэша: #{inspect(dto)}")

    Task.Supervisor.start_child(
      WorkerSupervisor,
      fn -> crack_hash_and_send_results(dto) end,
      restart: :transient
    )

    :ok
  end

  def crack_hash_and_send_results(%DTO{} = dto) do
    Logger.info("Начинаю взлом хэша: #{inspect(dto)}")
    answers = crack_hash(dto)
    Process.sleep(10_000)

    :ok =
      ManagerClient.send_result(%ManagerClient.DTO{
        request_id: dto.request_id,
        part_number: dto.part_number,
        answers: answers
      })
  end

  @doc false
  @spec crack_hash(DTO.t()) :: list()
  def crack_hash(%DTO{} = dto) do
    total_elements = Math.total_combinations(dto.max_length, String.length(dto.alphabet))

    dto.alphabet
    |> String.graphemes()
    |> Math.selections_with_max_length_stream(dto.max_length)
    |> Stream.drop(Math.part_offset(dto.part_number, dto.part_count, total_elements))
    |> Stream.take(Math.part_size(dto.part_number, dto.part_count, total_elements))
    |> Flow.from_enumerable()
    |> Flow.map(&crack_selection(&1, dto.hash))
    |> Flow.reject(&is_nil/1)
    |> Enum.to_list()
  end

  defp crack_selection(selection, hash) when is_list(selection) do
    word = Enum.join(selection)
    word_hash = :crypto.hash(:md5, word) |> Base.encode16()

    if word_hash == String.upcase(hash) do
      Logger.info("Хэш #{hash} взломан! Ответ: #{word}")
      word
    end
  end
end

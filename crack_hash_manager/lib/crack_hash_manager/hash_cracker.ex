defmodule CrackHashManager.HashCracker do
  @moduledoc """
  Основной модуль модели менеджера взлома хэшей: оперирует модулями более низкого уровня.
  """
  alias CrackHashManager.Clients.Workers, as: WorkersClient
  alias CrackHashManager.JobsStorage
  alias CrackHashManager.Math

  require Logger

  @alphabet ?a..?z |> Enum.map(&to_string([&1])) |> Enum.concat(0..9) |> Enum.join()
  @alphabet_length String.length(@alphabet)

  @doc """
  Начинает выполнение распределенной задачи по взлому хэша. Возвращает `request_id`, по которому потом можно будет получить результат
  """
  @spec start_job(String.t(), pos_integer()) :: String.t()
  def start_job(hash, max_length) do
    request_id = UUID.uuid1()
    workers_count = WorkersClient.workers_count()
    Logger.info("Adding request #{request_id} to storage with workers count #{workers_count}")
    parts_to_wait = 1..workers_count |> Enum.to_list()
    :ok = JobsStorage.add_request_id(request_id, parts_to_wait)
    start_workers(request_id, hash, max_length, workers_count)
    request_id
  end

  @doc """
  Принимает результаты от воркера для заявки `request_id` и сохраняет их.
  """
  @spec recieve_results(String.t(), [String.t()], integer()) ::
          :ok | {:error, :not_found | :request_is_ready | :already_added}
  def recieve_results(request_id, words_answers, part_number) do
    Logger.info("Recieved results for #{request_id}: #{inspect(words_answers)}")

    case JobsStorage.add_results(request_id, words_answers, part_number) do
      :ok ->
        Logger.info("Recieved results for #{request_id}: success")
        :ok

      {:error, :not_found} ->
        Logger.warn("Request #{request_id} was not found in storage")
        {:error, :not_found}

      {:error, :part_number_not_found} ->
        Logger.warn("Request #{request_id}: part_number #{part_number} was not found")
        {:error, :part_number_not_found}
    end
  end

  @doc """
  Возвращает результаты взлома хэша по `request_id`.
  """
  @spec get_results(String.t()) :: {:ok, [String.t()]} | :in_progress | {:error, :not_found}
  def get_results(request_id) do
    Logger.info("Retrieving results for #{request_id}...")

    case JobsStorage.get_results(request_id) do
      # Возможно, стоит удалять результаты из хранилища после получения, чтобы оно не разрасталось до бесконечности
      # И по таймеру чистить. Но это уже оптимизации
      {results, [] = _parts_to_wait} ->
        Logger.info("Returning resuls for #{request_id}: #{inspect(results)}")
        {:ok, results}

      {_results, parts_to_wait} when is_list(parts_to_wait) ->
        Logger.info(
          "Request #{request_id} is in progress: waiting for parts #{inspect(parts_to_wait)}"
        )

        :in_progress

      error ->
        Logger.warn("Error while retrieving results: #{inspect(error)}")
        error
    end
  end

  defp start_workers(request_id, hash, max_length, workers_count) do
    Task.Supervisor.async_stream(
      CrackHashManager.WorkersSupervisor,
      1..workers_count,
      fn part_number ->
        total_combinations_count = Math.total_combinations(max_length, @alphabet_length)
        part_count = Math.part_count(part_number, workers_count, total_combinations_count)

        Logger.info("Sending request for #{request_id} part_number #{part_number}...")

        WorkersClient.send(%WorkersClient.DTO{
          request_id: request_id,
          alphabet: @alphabet,
          hash: hash,
          max_length: max_length,
          part_count: part_count,
          part_number: part_number
        })
      end,
      # В случае ошибки для конкретного part_number будет перезапускать 3 раза в течении 5 секунд (дефолт)
      restart: :transient
    )
    |> Stream.run()
  end
end

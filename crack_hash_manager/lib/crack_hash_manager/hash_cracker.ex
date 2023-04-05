defmodule CrackHashManager.HashCracker do
  @moduledoc """
  Основной модуль модели менеджера взлома хэшей: оперирует модулями более низкого уровня.
  """
  alias CrackHashManager.Clients.Workers, as: WorkersClient
  alias CrackHashManager.JobsStorage
  alias CrackHashManager.Sender

  require Logger

  @alphabet ?a..?z |> Enum.map(&to_string([&1])) |> Enum.concat(0..9) |> Enum.join()

  @doc """
  Начинает выполнение распределенной задачи по взлому хэша. Возвращает `request_id`, по которому потом можно будет получить результат
  """
  @spec start_job(String.t(), pos_integer()) :: String.t()
  def start_job(hash, max_length) do
    request_id = UUID.uuid1()
    workers_count = WorkersClient.workers_count()
    Logger.info("Adding request #{request_id} to storage with workers count #{workers_count}")
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
    end
  end

  @doc """
  Возвращает результаты взлома хэша по `request_id`.
  """
  @spec get_results(String.t()) :: {:ok, [String.t()]} | :in_progress | {:error, :not_found}
  def get_results(request_id) do
    Logger.info("Retrieving results for #{request_id}...")

    request_id
    |> JobsStorage.get_jobs()
    |> retrieve_results_from_jobs()
    |> case do
      {:ok, results} ->
        Logger.info("Returning resuls for #{request_id}: #{inspect(results)}")
        {:ok, results}

      {:in_progress, parts_to_wait} ->
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
    1..workers_count
    |> Enum.map(fn part_number ->
      %WorkersClient.DTO{
        request_id: request_id,
        alphabet: @alphabet,
        hash: hash,
        max_length: max_length,
        part_count: workers_count,
        part_number: part_number
      }
    end)
    |> Sender.send()
  end

  defp retrieve_results_from_jobs([] = _jobs), do: {:error, :not_found}

  defp retrieve_results_from_jobs(jobs) when is_list(jobs) do
    jobs
    |> Enum.reject(&is_list(&1.results))
    |> case do
      [] ->
        results = jobs |> Enum.flat_map(& &1.results) |> Enum.uniq() |> Enum.sort()
        {:ok, results}

      not_finished_jobs ->
        parts_to_wait = Enum.map(not_finished_jobs, & &1.part_number) |> Enum.sort()
        {:in_progress, parts_to_wait}
    end
  end
end

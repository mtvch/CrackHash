defmodule CrackHashManager.Sender do
  @moduledoc """
  В данном модуле реализована логика отправки failed сообщений воркерам
  """

  alias CrackHashManager.Clients.Workers, as: WorkersClient
  alias CrackHashManager.JobsStorage

  require Logger

  @doc """
  Переотправляет по какой-то причине не отправленные сообщения воркерам
  """
  @spec resend() :: :ok
  def resend do
    JobsStorage.get_not_sent_jobs()
    |> Enum.map(&job_to_client_dto/1)
    |> send()
  end

  @doc """
  Отправляет запросы воркерам и сохраняет информацию о запросах в базе
  """
  @spec send([WorkersClient.DTO.t()]) :: :ok
  def send(client_dtos) do
    Task.Supervisor.async_stream(
      CrackHashManager.WorkersSupervisor,
      client_dtos,
      fn dto ->
        Logger.info("Sending request for #{dto.request_id} part_number #{dto.part_number}...")

        dto
        |> WorkersClient.send()
        |> store_job(dto)
      end,
      ordered: false,
      timeout: 30_000,
      # В случае ошибки для конкретного part_number будет перезапускать 3 раза в течении 5 секунд (дефолт)
      restart: :transient
    )
    |> Stream.run()
  end

  defp job_to_client_dto(%JobsStorage.Job{} = job) do
    %WorkersClient.DTO{
      request_id: job.request_id,
      alphabet: job.alphabet,
      hash: job.hash,
      max_length: job.max_length,
      part_count: job.part_count,
      part_number: job.part_number
    }
  end

  defp store_job(result, dto) do
    dto
    |> Map.take([:request_id, :alphabet, :hash, :max_length, :part_count, :part_number])
    |> Map.merge(%{is_sent: result == :ok})
    |> then(&struct(JobsStorage.Job, &1))
    |> JobsStorage.store()
  end
end

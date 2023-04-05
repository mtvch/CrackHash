defmodule CrackHashWorkerWeb.RMQEndpoint do
  @moduledoc """
  В данном модуле описана обработка сообщений из RabbitMQ
  """

  use Broadway

  alias CrackHashWorker.Worker
  alias CrackHashWorkerWeb.Parser

  require Logger

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module:
          {BroadwayRabbitMQ.Producer,
           queue: queue(),
           declare: [durable: true],
           on_failure: :reject_and_requeue,
           connection: rmq_url()},
        concurrency: 1
      ],
      processors: [
        start_job: [
          concurrency: 5
        ]
      ]
    )
  end

  @impl true
  def handle_message(:start_job, %Broadway.Message{data: data} = message, _) do
    Logger.info("Получил сообщение: #{inspect(data)}")

    case Parser.parse_manager_request(data) do
      %Worker.DTO{} = params ->
        :ok = Worker.crack_hash_and_send_results(params)

      error ->
        Logger.error("Ошибка при обоработке сообщения: #{inspect(error)}")

        nil
    end

    message
  end

  defp queue, do: CrackHashWorker.fetch_env!(__MODULE__, :queue)
  defp rmq_url, do: CrackHashWorker.fetch_env!(__MODULE__, :rmq_url)
end

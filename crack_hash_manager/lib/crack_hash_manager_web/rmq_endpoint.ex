defmodule CrackHashManagerWeb.RMQEndpoint do
  @moduledoc """
  В данном модуле описана обработка сообщений из RabbitMQ
  """

  use Broadway

  alias CrackHashManager.HashCracker
  alias CrackHashManagerWeb.Parser

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
        receive_results: [
          concurrency: 5
        ]
      ]
    )
  end

  @impl true
  def handle_message(:receive_results, %Broadway.Message{data: data} = message, _) do
    Logger.info("Получил сообщение: #{inspect(data)}")

    case Parser.parse_worker_response(data) do
      %{} = params ->
        :ok =
          HashCracker.recieve_results(
            params.request_id,
            params.words_answers,
            params.part_number
          )

      error ->
        Logger.error("Ошибка при обоработке сообщения: #{inspect(error)}")
        nil
    end

    message
  end

  defp queue, do: CrackHashManager.fetch_env!(__MODULE__, :queue)
  defp rmq_url, do: CrackHashManager.fetch_env!(__MODULE__, :rmq_url)
end

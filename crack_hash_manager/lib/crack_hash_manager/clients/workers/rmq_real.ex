defmodule CrackHashManager.Clients.Workers.RMQReal do
  @moduledoc """
  Клиент, который отправляет ответ запрос воркеру на взлом хэша и использует очередь Rabbit MQ
  """
  require Logger

  alias CrackHashManager.Clients.Workers, as: WorkersClient
  alias CrackHashManager.Clients.Workers.DTO

  @behaviour WorkersClient
  @request_template_path "lib/crack_hash_manager/clients/workers/real/request_template.xml.eex"
  @request_template @request_template_path |> File.read!()
  @external_resource @request_template_path

  @impl true
  @doc false
  def init do
    {:ok, channel} = try_get_channel()
    :ok = AMQP.Exchange.direct(channel, exchange(), durable: true)
  end

  @impl true
  @doc false
  def send(%DTO{} = dto) do
    xml_body =
      EEx.eval_string(@request_template,
        assigns: [
          request_id: dto.request_id,
          part_number: dto.part_number,
          part_count: dto.part_count,
          hash: dto.hash,
          max_length: dto.max_length,
          alphabet: dto.alphabet
        ]
      )

    Logger.info("Отправляю запрос в rmq: #{xml_body}")

    with {:ok, channel} <- AMQP.Application.get_channel(:producer),
         :ok <-
           AMQP.Basic.publish(channel, exchange(), routing_key(), xml_body,
             persistent: true,
             content_type: "application/xml",
             mandatory: true
           ) do
      Logger.info("Запрос отправлен успешно")
      :ok
    else
      error ->
        Logger.error("Ошибка при отправлении запроса: #{inspect(error)}")
        error
    end
  end

  # RabbitMQ долго стартует, поэтому на старте приложения надо немного подождать
  defp try_get_channel(retries_left \\ 20) do
    case AMQP.Application.get_channel(:producer) do
      {:ok, channel} ->
        {:ok, channel}

      error ->
        Logger.warn(
          "Попыток осталось: #{retries_left}. Ошибка при получении RabbitMQ канала: #{inspect(error)}"
        )

        Process.sleep(1000)
        try_get_channel(retries_left - 1)
    end
  end

  @impl true
  @doc false
  def workers_count, do: CrackHashManager.fetch_env!(__MODULE__, :workers_count)

  defp exchange, do: CrackHashManager.fetch_env!(__MODULE__, :exchange)
  defp routing_key, do: CrackHashManager.fetch_env!(__MODULE__, :routing_key)
end

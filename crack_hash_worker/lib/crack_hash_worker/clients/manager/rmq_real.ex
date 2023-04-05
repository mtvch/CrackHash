defmodule CrackHashWorker.Clients.Manager.RMQReal do
  @moduledoc """
  Клиент, который отправляет ответ воркера менеджеру и используется в проде
  """

  require Logger

  alias CrackHashWorker.Clients.Manager, as: ManagerClient
  alias CrackHashWorker.Clients.Manager.DTO

  @request_template_path "lib/crack_hash_worker/clients/manager/real/request_template.xml.eex"
  @request_template @request_template_path |> File.read!()
  @external_resource @request_template_path

  @behaviour ManagerClient

  @impl true
  @doc false
  def init do
    {:ok, channel} = try_get_channel()
    :ok = AMQP.Exchange.direct(channel, exchange(), durable: true)
  end

  @impl true
  @doc false
  def send_result(%DTO{} = dto) do
    xml_body =
      EEx.eval_string(@request_template,
        assigns: [request_id: dto.request_id, part_number: dto.part_number, answers: dto.answers]
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

  defp exchange, do: CrackHashWorker.fetch_env!(__MODULE__, :exchange)
  defp routing_key, do: CrackHashWorker.fetch_env!(__MODULE__, :routing_key)
end

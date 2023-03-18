defmodule CrackHashManager.Clients.Workers.Real do
  @moduledoc """
  Клиент, который отправляет ответ воркера менеджеру и используется в проде
  """
  require Logger

  alias CrackHashManager.Clients.Workers, as: WorkersClient
  alias CrackHashManager.Clients.Workers.DTO
  alias CrackHashManager.FinchHTTP

  @behaviour WorkersClient
  @request_template_path "lib/crack_hash_manager/clients/workers/real/request_template.xml.eex"
  @request_template @request_template_path |> File.read!()
  @external_resource @request_template_path

  defmodule RoundRobin do
    @moduledoc """
    Выдает endpoint'ы воркеров по кругу для балансировки нагрузки
    """
    use Agent

    def start_link(endpoints) do
      Agent.start_link(fn -> endpoints end, name: __MODULE__)
    end

    def get_endpoint do
      endpoint = Agent.get(__MODULE__, &hd/1)
      Agent.update(__MODULE__, fn [h | t] -> t ++ [h] end)
      endpoint
    end
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

    manager_url = "#{RoundRobin.get_endpoint()}/internal/api/worker/hash/crack/task"
    Logger.info("Отправляю запрос на #{manager_url}: #{xml_body}")

    Finch.build(:post, manager_url, [{"content_type", "text/xml"}], xml_body)
    |> Finch.request(FinchHTTP)
    |> case do
      {:ok, _} -> :ok
      error -> error
    end
  end

  @impl true
  @doc false
  def workers_count, do: workers_endpoints() |> length()

  def workers_endpoints, do: CrackHashManager.fetch_env!(__MODULE__, :workers_endpoints)
end

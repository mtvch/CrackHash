defmodule CrackHashWorker.Clients.Manager.Real do
  @moduledoc """
  Клиент, который отправляет ответ воркера менеджеру и используется в проде
  """

  require Logger

  alias CrackHashWorker.Clients.Manager, as: ManagerClient
  alias CrackHashWorker.Clients.Manager.DTO
  alias CrackHashWorker.FinchHTTP

  @request_template_path "lib/crack_hash_worker/clients/manager/real/request_template.xml.eex"
  @request_template @request_template_path |> File.read!()
  @external_resource @request_template_path

  @behaviour ManagerClient

  @impl true
  @doc false
  def init, do: :ok

  @impl true
  @doc false
  def send_result(%DTO{} = dto) do
    xml_body =
      EEx.eval_string(@request_template,
        assigns: [request_id: dto.request_id, part_number: dto.part_number, answers: dto.answers]
      )

    worker_url = "#{manager_endpoint()}/internal/api/manager/hash/crack/request"
    Logger.info("Отправляю запрос на #{worker_url}: #{xml_body}")

    Finch.build(:patch, worker_url, [{"content_type", "text/xml"}], xml_body)
    |> Finch.request(FinchHTTP)
    |> case do
      {:ok, _} -> :ok
      error -> error
    end
  end

  defp manager_endpoint, do: CrackHashWorker.fetch_env!(__MODULE__, :manager_endpoint)
end

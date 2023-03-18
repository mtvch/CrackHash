defmodule CrackHashWorkerWeb.Endpoint do
  @moduledoc """
  Входная точка HTTP запросов к сервису.
  """

  # Plug provides Plug.Router to dispatch incoming requests based on the path and method.
  # When the router is called, it will invoke the :match plug, represented by a match/2function responsible
  # for finding a matching route, and then forward it to the :dispatch plug which will execute the matched code.
  use Plug.Router

  alias CrackHashWorker.Worker
  alias CrackHashWorkerWeb.Parser
  alias CrackHashWorkerWeb.View

  # Using Plug.Logger for logging request information
  plug Plug.Logger

  # responsible for matching routes
  plug :match

  plug :fetch_query_params

  # responsible for dispatching responses
  plug :dispatch

  # Запрос от пользователя
  post "/internal/api/worker/hash/crack/task" do
    {:ok, xml_body, conn} = Plug.Conn.read_body(conn)

    case Parser.parse_manager_request(xml_body) do
      %Worker.DTO{} = params ->
        Worker.start_job(params)
        resp_body = View.ok_manager_xml_response(params.request_id)
        send_xml(conn, resp_body, 200)

      error ->
        resp_body = View.error_manager_xml_response(error)
        send_xml(conn, resp_body, 400)
    end
  end

  # A catchall route, 'match' will match no matter the request method,
  # so a response is always returned, even if there is no route to match.
  match _ do
    send_resp(conn, 404, "Unknown request!")
  end

  defp send_xml(conn, body, code) do
    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(code, body)
  end
end

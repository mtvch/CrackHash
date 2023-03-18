defmodule CrackHashManagerWeb.Endpoint do
  @moduledoc """
  Входная точка HTTP запросов к сервису.
  """

  # Plug provides Plug.Router to dispatch incoming requests based on the path and method.
  # When the router is called, it will invoke the :match plug, represented by a match/2function responsible
  # for finding a matching route, and then forward it to the :dispatch plug which will execute the matched code.
  use Plug.Router

  alias CrackHashManager.HashCracker
  alias CrackHashManagerWeb.Parser
  alias CrackHashManagerWeb.View

  # Using Plug.Logger for logging request information
  plug Plug.Logger

  # responsible for matching routes
  plug :match

  # Using Poison for JSON decoding
  # Note, order of plugs is important, by placing this _after_ the 'match' plug,
  # we will only parse the request AFTER there is a route match.
  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison

  plug :fetch_query_params

  # responsible for dispatching responses
  plug :dispatch

  # Запрос от пользователя
  post "/api/hash/crack" do
    case Parser.parse_user_crack_request(conn.body_params) do
      %{} = params ->
        request_id = HashCracker.start_job(params.hash, params.max_length)
        resp_body = View.ok_user_crack_json_response(request_id)
        send_json(conn, resp_body, 200)

      error ->
        resp_body = View.error_user_crack_json_response(error)
        send_json(conn, resp_body, 400)
    end
  end

  get "/api/hash/status" do
    with %{request_id: request_id} <- Parser.parse_user_status_request(conn.query_params),
         {:ok, results} <- HashCracker.get_results(request_id) do
      resp_body = View.ok_user_status_json_response(results)
      send_json(conn, resp_body, 200)
    else
      :in_progress ->
        resp_body = View.in_progress_user_status_json_response()
        send_json(conn, resp_body, 202)

      error ->
        resp_body = View.error_user_status_json_response(error)
        send_json(conn, resp_body, 400)
    end
  end

  # Колбек от воркера
  patch "/internal/api/manager/hash/crack/request" do
    {:ok, xml_body, conn} = Plug.Conn.read_body(conn)

    with %{} = params <- Parser.parse_worker_response(xml_body),
         :ok <-
           HashCracker.recieve_results(
             params.request_id,
             params.words_answers,
             params.part_number
           ) do
      resp_body = View.ok_worker_xml_response(params.request_id)
      send_xml(conn, resp_body, 200)
    else
      error ->
        resp_body = View.error_worker_xml_response(error)
        send_xml(conn, resp_body, 400)
    end
  end

  # A catchall route, 'match' will match no matter the request method,
  # so a response is always returned, even if there is no route to match.
  match _ do
    send_resp(conn, 404, "Unknown request!")
  end

  defp send_json(conn, body, code) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(code, body)
  end

  defp send_xml(conn, body, code) do
    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(code, body)
  end
end

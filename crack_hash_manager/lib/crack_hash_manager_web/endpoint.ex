defmodule CrackHashManagerWeb.Endpoint do
  @moduledoc """
  Входная точка HTTP запросов к сервису.
  """

  # Plug provides Plug.Router to dispatch incoming requests based on the path and method.
  # When the router is called, it will invoke the :match plug, represented by a match/2function responsible
  # for finding a matching route, and then forward it to the :dispatch plug which will execute the matched code.
  use Plug.Router

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

  # responsible for dispatching responses
  plug :dispatch

  get "/test" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{response: "This a test message !"}))
  end

  # A catchall route, 'match' will match no matter the request method,
  # so a response is always returned, even if there is no route to match.
  match _ do
    send_resp(conn, 404, "Unknown request!")
  end
end

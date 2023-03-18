defmodule CrackHashWorkerWeb.EndpointTest do
  use ExUnit.Case
  use Plug.Test

  alias CrackHashWorkerWeb.Endpoint

  @opts Endpoint.init([])

  @parser_dir "test/crack_hash_worker_web/parser_test"
  @bad_manager_request "#{@parser_dir}/bad_request_example.xml" |> File.read!()
  @manager_request "#{@parser_dir}/request_example.xml" |> File.read!()

  test "Запрос от менеджера на взлом хэша" do
    conn =
      :post
      |> conn("/internal/api/worker/hash/crack/task", @manager_request)
      |> Endpoint.call(@opts)

    assert conn.status == 200
    assert conn.resp_body =~ "<Status>ok</Status>"
  end

  test "Отправка запроса на взлом: неправильный формат запроса" do
    conn =
      :post
      |> conn("/internal/api/worker/hash/crack/task", @bad_manager_request)
      |> Endpoint.call(@opts)

    assert conn.status == 400
    assert conn.resp_body =~ "Bad params"
  end

  test "Маршрут не найден" do
    conn =
      :get
      |> conn("/", "")
      |> Endpoint.call(@opts)

    assert conn.status == 404
    assert conn.resp_body == "Unknown request!"
  end
end

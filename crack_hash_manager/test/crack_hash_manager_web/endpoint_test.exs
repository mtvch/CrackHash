defmodule CrackHashManagerWeb.EndpointTest do
  use ExUnit.Case
  use Plug.Test

  import Mock

  alias CrackHashManagerWeb.Endpoint

  @opts Endpoint.init([])

  @dir "test/crack_hash_manager_web/endpoint_test"
  @expected_user_crack_request_body "#{@dir}/expected_user_crack_request_body.json"
                                    |> File.read!()
  @worker_response_1 "#{@dir}/worker_response_1.xml" |> File.read!()
  @worker_response_2 "#{@dir}/worker_response_2.xml" |> File.read!()

  @request_id "ec8a4d9a-bfc4-11ed-b9a2-acde48001122"

  setup do
    Mongo.command(:mongo, %{dropDatabase: 1})
  end

  test_with_mock "Полный цикл взлома хэша", UUID, uuid1: fn -> @request_id end do
    conn =
      :post
      |> conn("/api/hash/crack", @expected_user_crack_request_body)
      |> put_req_header("content-type", "application/json")
      |> Endpoint.call(@opts)

    assert conn.status == 200

    assert %{"request_id" => @request_id, "ok" => true} == Poison.decode!(conn.resp_body)

    conn =
      :get
      |> conn("/api/hash/status?requestId=#{@request_id}")
      |> Endpoint.call(@opts)

    assert conn.status == 202
    assert conn.resp_body == "{\"status\":\"IN_PROGRESS\",\"ok\":true,\"data\":null}"

    conn =
      :patch
      |> conn("/internal/api/manager/hash/crack/request", @worker_response_1)
      |> Endpoint.call(@opts)

    assert conn.status == 200

    conn =
      :patch
      |> conn("/internal/api/manager/hash/crack/request", @worker_response_2)
      |> Endpoint.call(@opts)

    assert conn.status == 200

    conn =
      :get
      |> conn("/api/hash/status?requestId=#{@request_id}")
      |> Endpoint.call(@opts)

    assert conn.status == 200

    assert conn.resp_body ==
             "{\"status\":\"READY\",\"ok\":true,\"data\":[\"WORD_1\",\"WORD_2\",\"WORD_3\"]}"
  end

  test "Отправка заявки на взлом хэша: не указали content-type" do
    conn =
      :post
      |> conn("/api/hash/crack", @expected_user_crack_request_body)
      |> Endpoint.call(@opts)

    assert conn.status == 400
    assert conn.resp_body == "{\"ok\":false,\"error\":\"Bad params\"}"
  end

  test "Отправка заявки на получение результатов по несуществующей заявке" do
    conn =
      :get
      |> conn("/api/hash/status?requestId=bad")
      |> Endpoint.call(@opts)

    assert conn.status == 400
    assert conn.resp_body == "{\"ok\":false,\"error\":\"Not found\"}"
  end

  test "Отправка результатов воркером по несуществующей заявке" do
    conn =
      :patch
      |> conn("/internal/api/manager/hash/crack/request", @worker_response_2)
      |> Endpoint.call(@opts)

    assert conn.status == 400
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

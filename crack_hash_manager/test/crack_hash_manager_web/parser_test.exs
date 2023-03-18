defmodule CrackHashManagerWeb.ParserTest do
  use ExUnit.Case, async: true

  alias CrackHashManagerWeb.Parser

  @dir "test/crack_hash_manager_web/parser_test"
  @worker_response_xsd_path "#{@dir}/worker_response.xsd"
  @response_example_path "#{@dir}/response_example.xml"
  @response_example File.read!(@response_example_path)
  @bad_response_example_path "#{@dir}/bad_response_example.xml"
  @bad_response_example File.read!(@bad_response_example_path)

  test "xml соответствует xsd" do
    {xml, _} = :xmerl_scan.file(to_charlist(@response_example_path))
    {:ok, xsd} = :xmerl_xsd.process_schema(to_charlist(@worker_response_xsd_path))
    res = :xmerl_xsd.validate(xml, xsd)
    assert elem(res, 0) != :error
  end

  test "Парсит валидный xml ответ воркера" do
    assert %{
             part_number: 1,
             request_id: "ec8a4d9a-bfc4-11ed-b9a2-acde48001122",
             words_answers: ["test_word", "another_test_word"]
           } == Parser.parse_worker_response(@response_example)
  end

  test "Не валидный xml не соответствует xsd" do
    {xml, _} = :xmerl_scan.file(to_charlist(@bad_response_example_path))
    {:ok, xsd} = :xmerl_xsd.process_schema(to_charlist(@worker_response_xsd_path))
    res = :xmerl_xsd.validate(xml, xsd)
    assert elem(res, 0) == :error
  end

  test "Ошибка парсинга не валидного xml" do
    assert {:error, :bad_params} == Parser.parse_worker_response(@bad_response_example)
  end

  test "Парсинг запроса от пользователя на взлом" do
    request_body = %{"hash" => "123", "maxLength" => 5}

    assert %{hash: "123", max_length: 5} == Parser.parse_user_crack_request(request_body)
  end

  test "Ошибка на плохой запрос от пользователя на взлом" do
    request_body = %{"hash" => "123", "maxLength" => "5"}

    assert {:error, :bad_params} == Parser.parse_user_crack_request(request_body)
  end

  test "Парсинг запроса от пользователя на получение статуса" do
    request_id = "ec8a4d9a-bfc4-11ed-b9a2-acde48001122"
    request_body = %{"requestId" => request_id}
    assert %{request_id: request_id} == Parser.parse_user_status_request(request_body)
  end

  test "Ошибка на плохой запрос от пользователя на получение статуса" do
    request_id = "ec8a4d9a-bfc4-11ed-b9a2-acde48001122"
    request_body = %{"reque_id" => request_id}

    assert {:error, :bad_params} == Parser.parse_user_status_request(request_body)
  end
end

defmodule CrackHashWorkerWeb.ParserTest do
  use ExUnit.Case, async: true

  alias CrackHashWorker.Worker
  alias CrackHashWorkerWeb.Parser

  @dir "test/crack_hash_worker_web/parser_test"
  @manager_request_xsd_path "#{@dir}/manager_request.xsd"
  @request_example_path "#{@dir}/request_example.xml"
  @request_example File.read!(@request_example_path)
  @bad_request_example_path "#{@dir}/bad_request_example.xml"
  @bad_request_example File.read!(@bad_request_example_path)

  test "xml соответствует xsd" do
    {xml, _} = :xmerl_scan.file(to_charlist(@request_example_path))
    {:ok, xsd} = :xmerl_xsd.process_schema(to_charlist(@manager_request_xsd_path))
    res = :xmerl_xsd.validate(xml, xsd)
    assert elem(res, 0) != :error
  end

  test "Парсит валидный xml ответ воркера" do
    assert %Worker.DTO{
             part_number: 2,
             request_id: "ec8a4d9a-bfc4-11ed-b9a2-acde48001122",
             alphabet: "abcd1234",
             hash: "e2fc714c4727ee9395f324cd2e7f331f",
             max_length: 4,
             part_count: 3
           } == Parser.parse_manager_request(@request_example)
  end

  test "Не валидный xml не соответствует xsd" do
    {xml, _} = :xmerl_scan.file(to_charlist(@bad_request_example_path))
    {:ok, xsd} = :xmerl_xsd.process_schema(to_charlist(@manager_request_xsd_path))
    res = :xmerl_xsd.validate(xml, xsd)
    assert elem(res, 0) == :error
  end

  test "Ошибка парсинга не валидного xml" do
    assert {:error, :bad_params} == Parser.parse_manager_request(@bad_request_example)
  end
end

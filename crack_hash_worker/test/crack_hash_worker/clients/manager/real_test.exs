defmodule CrackHashWorker.Clients.Manager.RealTest do
  use ExUnit.Case

  import Mock

  alias CrackHashWorker.Clients.Manager

  @dir "test/crack_hash_worker/clients/manager/real_test"
  @expected_request_path "#{@dir}/expected_request.xml"
  @expected_request @expected_request_path |> File.read!()
  @request_xsd_path "#{@dir}/request.xsd"

  test_with_mock "Вызов продовского клиента", Finch,
    build: fn _method, _url, _headers, _body -> %{} end,
    request: fn _req, _finch -> {:ok, %{}} end do
    assert :ok ==
             Manager.Real.send_result(%Manager.DTO{
               request_id: "ec8a4d9a-bfc4-11ed-b9a2-acde48001122",
               part_number: 1,
               answers: ["WORD_1", "WORD_2"]
             })

    assert_called(
      Finch.build(
        :patch,
        "http://localhost:4000/internal/api/manager/hash/crack/request",
        [{"content_type", "text/xml"}],
        @expected_request
      )
    )
  end

  test "xml соответствует xsd" do
    {xml, _} = :xmerl_scan.file(to_charlist(@expected_request_path))
    {:ok, xsd} = :xmerl_xsd.process_schema(to_charlist(@request_xsd_path))
    res = :xmerl_xsd.validate(xml, xsd)
    assert elem(res, 0) != :error
  end
end

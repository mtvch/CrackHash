# defmodule CrackHashManager.Clients.Workers.RealTest do
#   use ExUnit.Case

#   import Mock

#   alias CrackHashManager.Clients.Workers

#   @dir "test/crack_hash_manager/clients/workers/real_test"
#   @expected_request_path "#{@dir}/expected_request.xml"
#   @expected_request @expected_request_path |> File.read!()
#   @request_xsd_path "#{@dir}/request.xsd"

#   test_with_mock "", Finch,
#     build: fn _method, _url, _headers, _body -> %{} end,
#     request: fn _req, _finch -> {:ok, %{}} end do
#     assert :ok ==
#              Workers.Real.send(%Workers.DTO{
#                request_id: "ec8a4d9a-bfc4-11ed-b9a2-acde48001122",
#                part_number: 1,
#                part_count: 2,
#                hash: "e2fc714c4727ee9395f324cd2e7f331f",
#                max_length: 4,
#                alphabet: "abcd"
#              })

#     assert_called(
#       Finch.build(
#         :post,
#         "http://localhost:4001/internal/api/worker/hash/crack/task",
#         [{"content_type", "text/xml"}],
#         @expected_request
#       )
#     )
#   end

#   test "workers_count/0" do
#     assert 1 == Workers.Real.workers_count()
#   end

#   test "xml соответствует xsd" do
#     {xml, _} = :xmerl_scan.file(to_charlist(@expected_request_path))
#     {:ok, xsd} = :xmerl_xsd.process_schema(to_charlist(@request_xsd_path))
#     res = :xmerl_xsd.validate(xml, xsd)
#     assert elem(res, 0) != :error
#   end
# end

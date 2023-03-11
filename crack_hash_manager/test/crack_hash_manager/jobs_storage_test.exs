defmodule CrackHashManager.JobsStorageTest do
  alias CrackHashManager.JobsStorage
  use ExUnit.Case

  test "Работа хранилища" do
    request_id = "eec0bd6c-c021-11ed-ad9c-acde48001122"
    assert :ok == JobsStorage.add_request_id(request_id, [1, 2])
    assert {[], [1, 2]} == JobsStorage.get_results(request_id)
    assert {:error, :not_found} == JobsStorage.get_results("non_existing_request_id")

    assert {:error, :not_found} ==
             JobsStorage.add_results("non_existing_request_id", ["WORD"], [1])

    assert :ok == JobsStorage.add_results(request_id, ["WORD_1", "WORD_2"], 1)
    assert {["WORD_1", "WORD_2"], [2]} == JobsStorage.get_results(request_id)

    assert :ok == JobsStorage.add_results(request_id, ["WORD_2", "WORD_3"], 2)
    assert {["WORD_2", "WORD_3", "WORD_1"], []} == JobsStorage.get_results(request_id)

    assert {:error, :part_number_not_found} == JobsStorage.add_results(request_id, ["WORD_4"], 2)
  end
end

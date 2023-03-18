defmodule CrackHashManager.HashCrackerTest do
  use ExUnit.Case

  import Mock

  alias CrackHashManager.Clients.Workers, as: WorkersClient
  alias CrackHashManager.Clients.Workers.DTO
  alias CrackHashManager.HashCracker

  test "Работа менеджера: клиент-затычка" do
    hash = "123"
    max_length = 5
    request_id = HashCracker.start_job(hash, max_length)
    assert :in_progress == HashCracker.get_results(request_id)
    assert :ok == HashCracker.recieve_results(request_id, ["WORD_1", "WORD_2"], 1)
    assert :in_progress == HashCracker.get_results(request_id)
    assert :ok == HashCracker.recieve_results(request_id, ["WORD_2", "WORD_3"], 2)
    assert {:ok, ["WORD_2", "WORD_3", "WORD_1"]} == HashCracker.get_results(request_id)
    assert {:error, :not_found} == HashCracker.get_results("bad_request_id")
  end

  test "Работа менеджера: мок клиента" do
    with_mock WorkersClient, [:passthrough], send: fn _dto -> :ok end do
      hash = "123"
      max_length = 3
      request_id = HashCracker.start_job(hash, max_length)

      assert_called_exactly(
        WorkersClient.send(%DTO{
          request_id: request_id,
          part_number: 1,
          part_count: 2,
          hash: "123",
          max_length: 3,
          alphabet: "abcdefghijklmnopqrstuvwxyz0123456789"
        }),
        1
      )

      assert_called_exactly(
        WorkersClient.send(%DTO{
          request_id: request_id,
          part_number: 2,
          part_count: 2,
          hash: "123",
          max_length: 3,
          alphabet: "abcdefghijklmnopqrstuvwxyz0123456789"
        }),
        1
      )
    end
  end
end

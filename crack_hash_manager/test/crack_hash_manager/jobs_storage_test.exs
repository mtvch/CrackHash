defmodule CrackHashManager.JobsStorageTest do
  alias CrackHashManager.JobsStorage
  use ExUnit.Case

  setup do
    Mongo.command(:mongo, %{dropDatabase: 1})
  end

  @request_id "eec0bd6c-c021-11ed-ad9c-acde48001122"
  @job_fixture %JobsStorage.Job{
    request_id: @request_id,
    alphabet: "abc",
    hash: "xyz",
    is_sent: true,
    max_length: 4,
    part_count: 2
  }

  test "Работа хранилища" do
    job = %JobsStorage.Job{@job_fixture | part_number: 1, is_sent: false}
    assert :ok == JobsStorage.store(job)

    assert [
             %JobsStorage.Job{
               alphabet: "abc",
               hash: "xyz",
               is_sent: false,
               max_length: 4,
               part_count: 2,
               part_number: 1,
               request_id: @request_id,
               results: nil
             }
           ] = JobsStorage.get_jobs(@request_id)

    job = %JobsStorage.Job{@job_fixture | part_number: 1, is_sent: true}
    assert :ok == JobsStorage.store(job)

    assert [
             %JobsStorage.Job{
               alphabet: "abc",
               hash: "xyz",
               is_sent: true,
               max_length: 4,
               part_count: 2,
               part_number: 1,
               request_id: @request_id,
               results: nil
             }
           ] = JobsStorage.get_jobs(@request_id)

    assert :ok == JobsStorage.add_results(@request_id, ["WORD_1", "WORD_2"], 1)

    assert [
             %JobsStorage.Job{
               alphabet: "abc",
               hash: "xyz",
               is_sent: true,
               max_length: 4,
               part_count: 2,
               part_number: 1,
               request_id: @request_id,
               results: ["WORD_1", "WORD_2"]
             }
           ] = JobsStorage.get_jobs(@request_id)

    job = %JobsStorage.Job{@job_fixture | part_number: 3, is_sent: false}
    assert :ok == JobsStorage.store(job)
    assert [%JobsStorage.Job{part_number: 3}] = JobsStorage.get_not_sent_jobs()
  end
end

defmodule CrackHashWorker.WorkerTest do
  use ExUnit.Case, async: true

  alias CrackHashWorker.Worker

  @alphabet ?a..?z |> Enum.map(&to_string([&1])) |> Enum.concat(0..9) |> Enum.join()

  test "Простой пример взлома хэша" do
    assert ["abcd"] ==
             %Worker.DTO{
               hash: "e2fc714c4727ee9395f324cd2e7f331f",
               max_length: 4,
               part_number: 1,
               part_count: 1,
               alphabet: @alphabet
             }
             |> Worker.crack_hash()
  end
end

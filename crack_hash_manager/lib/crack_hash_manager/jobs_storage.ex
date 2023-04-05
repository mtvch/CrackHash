defmodule CrackHashManager.JobsStorage do
  @moduledoc """
  Модуль, который предоставляет возможность сохранять и получать информацию о запросах по взлому хэша
  """
  @collection "jobs"

  defmodule Job do
    @moduledoc """
    Модуль работы по взлому хэша, которую выполняет воркер
    """
    defstruct [
      :request_id,
      :part_number,
      :part_count,
      :hash,
      :max_length,
      :alphabet,
      :is_sent,
      :results
    ]

    def decode(%{} = job_from_db) do
      %CrackHashManager.JobsStorage.Job{
        request_id: job_from_db["request_id"],
        part_number: job_from_db["part_number"],
        part_count: job_from_db["part_count"],
        hash: job_from_db["hash"],
        max_length: job_from_db["max_length"],
        alphabet: job_from_db["alphabet"],
        is_sent: job_from_db["is_sent"],
        results: job_from_db["results"]
      }
    end
  end

  @doc """
  Сохраняет информацию о задаче на взлом хэша
  """
  @spec store(struct()) :: :ok
  def store(%Job{} = job) do
    Mongo.update_one(
      :mongo,
      @collection,
      %{"$and" => [%{"request_id" => job.request_id, "part_number" => job.part_number}]},
      %{
        "$set" => %{
          "part_count" => job.part_count,
          "hash" => job.hash,
          "max_length" => job.max_length,
          "alphabet" => job.alphabet,
          "is_sent" => job.is_sent
        }
      },
      w: :majority,
      wtimeout: 30_000,
      upsert: true
    )

    :ok
  end

  @doc """
  Сохраняет результаты выполнения задачи
  """
  @spec add_results(String.t(), list(), any()) :: :ok | {:error, :not_found}
  def add_results(request_id, results, part_number)
      when is_binary(request_id) and is_list(results) do
    Mongo.update_one(
      :mongo,
      @collection,
      %{
        "$and" => [%{"request_id" => request_id}, %{"part_number" => part_number}]
      },
      %{"$set" => %{"results" => results}}
    )
    |> case do
      {:ok, %Mongo.UpdateResult{modified_count: 1}} -> :ok
      _any -> {:error, :not_found}
    end
  end

  @doc """
  Получает хранимые результаты по заявке `request_id`.
  """
  @spec get_jobs(String.t()) :: [struct()]
  def get_jobs(request_id) when is_binary(request_id) do
    Mongo.find(:mongo, @collection, %{"request_id" => request_id})
    |> Enum.map(&Job.decode/1)
  end

  @doc """
  Получает все задачи, которые не получилось отправить воркерам
  """
  @spec get_not_sent_jobs() :: [struct()]
  def get_not_sent_jobs do
    Mongo.find(:mongo, @collection, %{"is_sent" => false})
    |> Enum.map(&Job.decode/1)
  end
end

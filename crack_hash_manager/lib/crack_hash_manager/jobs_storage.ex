defmodule CrackHashManager.JobsStorage do
  @moduledoc """
  Модуль, который предоставляет возможность сохранять и получать информацию о запросах по взлому хэша
  """
  alias CrackHashManager.JobsStorage.Engine
  alias CrackHashManager.JobsStorageRegistry
  alias CrackHashManager.JobsStorageSupervisor

  @doc """
  Добавляет `request_id` в хранилище.
  `parts_to_wait` - список из чисел. При добавлении результата с `part_number`, число будет удаляться из списка.
  """
  @spec add_request_id(String.t(), list()) :: :ok
  def add_request_id(request_id, parts_to_wait)
      when is_binary(request_id) and is_list(parts_to_wait) do
    {:ok, _pid} =
      DynamicSupervisor.start_child(JobsStorageSupervisor, %{
        id: request_id,
        start: {Engine, :start_link, [process_name(request_id), parts_to_wait]}
      })

    :ok
  end

  @doc """
  Добавляет результаты `results` к хранимым результатам по заявке `request_id`.
  `part_number` - номер части, результаты которой добавляем.

  ## Коды ошибки
  * `:not_found` - `request_id` не был найден в хранилище
  * `:part_number_not_found` - В списке `parts_to_wait` нет номер `part_number`. Возможно, его результат уже был добавлен
  """
  @spec add_results(String.t(), list(), any()) ::
          :ok | {:error, :not_found | :part_number_not_found}
  def add_results(request_id, results, part_number)
      when is_binary(request_id) and is_list(results) do
    case Registry.lookup(JobsStorageRegistry, request_id) do
      [] -> {:error, :not_found}
      [{pid, nil}] -> GenServer.call(pid, {:add_results, results, part_number})
    end
  end

  @doc """
  Получает хранимые результаты по заявке `request_id`.
  """
  @spec get_results(String.t()) ::
          {results :: list(), parts_to_wait :: list()} | {:error, :not_found}
  def get_results(request_id) when is_binary(request_id) do
    case Registry.lookup(JobsStorageRegistry, request_id) do
      [] -> {:error, :not_found}
      [{pid, nil}] -> GenServer.call(pid, :get)
    end
  end

  defp process_name(request_id) do
    {:via, Registry, {JobsStorageRegistry, request_id}}
  end
end

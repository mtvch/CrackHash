defmodule CrackHashManager.JobsStorage.Engine do
  @moduledoc """
  Сервер, который хранит информацию о запросах по взлому хэша и совершает атомарные операции по изменению состояния.
  Используется только через `CrackHashManager.JobsStorage`
  """
  use GenServer

  @doc false
  def start_link(name, parts_to_wait) do
    GenServer.start_link(__MODULE__, parts_to_wait, name: name)
  end

  @doc false
  @impl true
  def init(parts_to_wait) do
    {:ok, {[], parts_to_wait}}
  end

  @doc false
  @impl true
  def handle_call(
        {:add_results, results, part_number},
        _from,
        {current_results, parts_to_wait} = state
      ) do
    case List.delete(parts_to_wait, part_number) do
      ^parts_to_wait ->
        {:reply, {:error, :part_number_not_found}, state}

      new_parts_to_wait ->
        new_results = Enum.uniq(results ++ current_results)
        {:reply, :ok, {new_results, new_parts_to_wait}}
    end
  end

  @doc false
  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end
end

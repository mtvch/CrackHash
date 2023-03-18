defmodule CrackHashWorker.Math do
  @moduledoc """
  В данном модуле реализуются математические расчеты, используемые в воркере
  """

  @doc """
  Возвращает stream, который генерирует все варианты слов с алфавитом `alphabet` и максимальной длиной `max_length`.

  ## Примеры

      iex> selections_with_max_length_stream([1, 2], 2) |> Enum.to_list()
      [[1], [2], [1, 1], [1, 2], [2, 1], [2, 2]]
  """
  @spec selections_with_max_length_stream(list(), pos_integer()) :: Enumerable.t()
  def selections_with_max_length_stream(alphabet, max_length) do
    Stream.flat_map(1..max_length, &selections_stream(alphabet, &1))
  end

  defp selections_stream(_alphabet, 0), do: [[]]

  defp selections_stream(alphabet, length) do
    Stream.flat_map(alphabet, fn el ->
      Stream.map(selections_stream(alphabet, length - 1), &[el | &1])
    end)
  end

  @doc """
  Вычисляет, через сколько элементов начнется часть `part_number` в списке из `total_elements` элементов, который делят на `total_parts` частей

  ## Примеры

      iex> part_offset(1, 2, 5)
      0
      iex> part_offset(2, 2, 5)
      3
  """
  @spec part_offset(pos_integer(), pos_integer(), non_neg_integer()) :: non_neg_integer()
  def part_offset(part_number, total_parts, total_elements)

  def part_offset(1, _total_parts, _total_elements), do: 0

  def part_offset(part_number, total_parts, total_elements) do
    1..(part_number - 1)
    |> Enum.map(&part_size(&1, total_parts, total_elements))
    |> Enum.sum()
  end

  @doc """
  Вычисляет, сколько элементов будет в части `part_number` при равномерном распределении
  `total_elements` на `total_parts` частей.

  ## Примеры

      iex> part_size(1, 2, 5)
      3
      iex> part_size(2, 2, 5)
      2
      iex> part_size(1, 1, 1)
      1
  """
  @spec part_size(pos_integer(), pos_integer(), non_neg_integer()) :: non_neg_integer()
  def part_size(part_number, total_parts, total_elements) do
    min_bound = div(total_elements, total_parts)

    if part_number <= rem(total_elements, total_parts) do
      min_bound + 1
    else
      min_bound
    end
  end

  @doc """
  Вычисляет, сколько разных слов максимальной длины `word_max_length` можно составить из алфавита размером `alphabet_size`.

  ## Примеры

      iex> total_combinations(2, 2)
      6
      iex> total_combinations(3, 5)
      155
  """
  @spec total_combinations(pos_integer(), pos_integer()) :: pos_integer()
  def total_combinations(word_max_length, alphabet_size)
      when is_integer(word_max_length) and is_integer(alphabet_size) do
    1..word_max_length
    |> Enum.map(&combinations_count(&1, alphabet_size))
    |> Enum.sum()
  end

  defp combinations_count(word_length, alphabet_size), do: alphabet_size ** word_length
end

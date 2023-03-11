defmodule CrackHashManager.Math do
  @moduledoc """
  В данном модуле реализуются математические расчеты, используемые в менеджере
  """

  @doc """
  Вычисляет, сколько элементов будет в части `part_number` при равномерном распределении
  `total_elements` на `total_parts` частей.

  ## Примеры

      iex> part_count(1, 2, 5)
      3
      iex> part_count(2, 2, 5)
      2
      iex> part_count(1, 1, 1)
      1
  """
  @spec part_count(pos_integer(), pos_integer(), non_neg_integer()) :: non_neg_integer()
  def part_count(part_number, total_parts, total_elements) do
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
